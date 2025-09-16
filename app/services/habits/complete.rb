module Habits
  class Complete
    def initialize(habit:, completed:)
      @habit = habit
      @completed = ActiveModel::Type::Boolean.new.cast(completed)
    end

    def call
      ActiveRecord::Base.transaction do
        changed = @completed ? @habit.complete! : @habit.undo_complete!

        unless changed
          return Result.failure(@completed ? "Failed to complete habit." : "Failed to mark habit incomplete.")
        end

        # Update progress and streak synchronously for immediate UI feedback
        Habits::ProgressCalculator.new(@habit).calculate_and_save!
        Habits::StreakCalculator.new(@habit).calculate_and_save!

        Result.success({ habit: @habit, completed: @completed })
      end
    rescue => e
      Result.failure(e.message)
    end

    private

    attr_reader :habit, :completed
  end
end
