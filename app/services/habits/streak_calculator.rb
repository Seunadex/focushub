module Habits
  class StreakCalculator
    PERIODS = {
      "daily" => {
        shift: ->(date) { date - 1.day },
        range: ->(date) { date..date }
      },
      "weekly" => {
        shift: ->(date) { date - 1.week },
        range: ->(date) {
          start_of_week = date.beginning_of_week(:monday)
          start_of_week..(start_of_week + 6.days)
        }
      },
      "bi-weekly" => {
        shift: ->(date) { date - 2.weeks },
        range: ->(date) {
          start_of_week = date.beginning_of_week(:monday)
          start_of_week..(start_of_week + 13.days)
        }
      },
      "monthly" => {
        shift: ->(date) { (date - 1.day).beginning_of_month },
        range: ->(date) { date.beginning_of_month..date.end_of_month }
      },
      "quarterly" => {
        shift: ->(date) { (date - 1.day).beginning_of_quarter },
        range: ->(date) { date.beginning_of_quarter..date.end_of_quarter }
      },
      "annually" => {
        shift: ->(date) { (date - 1.day).beginning_of_year },
        range: ->(date) { date.beginning_of_year..date.end_of_year }
      }
    }.freeze

    def initialize(habit)
      @habit = habit
    end

    # Calculate the current streak based on habit.frequency
    # Returns an integer count of consecutive completed periods
    def calculate
      period_key = @habit.frequency.to_s
      config = PERIODS.fetch(period_key, PERIODS["daily"])
      range_proc = config[:range]
      shift_proc = config[:shift]

      streak = 0
      date = Date.current

      while @habit.habit_completions.where(completed_on: range_proc.call(date)).count >= @habit.target
        streak += 1
        date = shift_proc.call(date)
      end

      streak
    end

    # Calculate and save the streak back to the habit
    def calculate_and_save!
      if current_period_incomplete_and_past?
        @habit.reset_streak!
      else
        @habit.update!(streak: calculate)
      end
    end

    private

    def current_period_incomplete_and_past?
      period_key = @habit.frequency.to_s
      config = PERIODS.fetch(period_key, PERIODS["daily"])
      range_proc = config[:range]

      date = Date.current
      current_range = range_proc.call(date)
      period_end = current_range.end

      # Only reset if the period has ended and the user did not meet the target
      Date.current > period_end &&
        @habit.habit_completions.where(completed_on: current_range).count < @habit.target
    end
  end
end
