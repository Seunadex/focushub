module Habits
  class ProgressCalculator
    def initialize(habit)
      @habit = habit
    end

    def call
      calculate_and_save!
    end

    def calculate_and_save!
      # Determine period range for counting
      range = period_range(@habit.frequency)
      # Count completed days within period
      completed_count = @habit.habit_completions
                            .where(completed_on: range)
                            .select(:completed_on)
                            .count

      # Compute progress percentage
      progress = if @habit.target.to_i <= 0
        0
      else
        [ (completed_count.to_f / @habit.target * 100), 100 ].min.round
      end

      # Persist and return
      @habit.update!(progress: progress)
      progress
    end

    private

    def period_range(freq)
      today = Date.current
      case freq.to_s
      when "daily"
        today..today
      when "weekly"
        start_of_week = today.beginning_of_week(:monday)
        start_of_week..(start_of_week + 6.days)
      when "bi-weekly"
        start_of_week = today.beginning_of_week(:monday)
        start_of_week..(start_of_week + 13.days)
      when "monthly"
        today.beginning_of_month..today.end_of_month
      when "quarterly"
        today.beginning_of_quarter..today.end_of_quarter
      when "annually"
        today.beginning_of_year..today.end_of_year
      else
        today..today
      end
    end
  end
end
