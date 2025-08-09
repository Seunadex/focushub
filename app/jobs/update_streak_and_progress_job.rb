class UpdateStreakAndProgressJob < ApplicationJob
  queue_as :default

  # Retry on transient DB contention
  retry_on ActiveRecord::Deadlocked, wait: :exponentially_longer, attempts: 5

  # Optionally run for a single habit by id. Otherwise processes all active habits in batches.
  # Usage examples:
  #   UpdateStreakAndProgressJob.perform_later
  #   UpdateStreakAndProgressJob.perform_later(habit_id: some_id)
  def perform(habit_id: nil)
    scope = Habit.active
    scope = scope.where(id: habit_id) if habit_id

    scope.select(:id).find_in_batches(batch_size: 200) do |batch|
      ids = batch.map(&:id)

      Habit.where(id: ids).find_each do |habit|
        begin
          Rails.logger.info("[UpdateStreakAndProgressJob] starting habit_id=#{habit.id}")

          # Ensure only one worker updates a habit at a time.
          habit.with_lock do
            Habits::ProgressCalculator.new(habit).calculate_and_save!
            Habits::StreakCalculator.new(habit).calculate_and_save!
          end

          Rails.logger.info("[UpdateStreakAndProgressJob] finished habit_id=#{habit.id}")
        rescue ActiveRecord::RecordNotFound
          next
        rescue => e
          Rails.logger.error("[UpdateStreakAndProgressJob] error habit_id=#{habit.id}: #{e.class} - #{e.message}")
          Rails.error&.report(e, handled: true, context: { job: self.class.name, habit_id: habit.id }) if Rails.respond_to?(:error)
          next
        end
      end
    end
  end
end
