module Habits
  class StreakCalculator
    PERIODS = {
      "daily" => {
        shift: ->(date) { date - 1.day },
        range: ->(date) { date..date },
        end_date: ->(date) { date }
      },
      "weekly" => {
        shift: ->(date) { date - 1.week },
        range: ->(date) {
          start_of_week = date.beginning_of_week(:monday)
          start_of_week..(start_of_week + 6.days)
        },
        end_date: ->(date) { date.beginning_of_week(:monday) + 6.days }
      },
      "bi-weekly" => {
        shift: ->(date) { date - 2.weeks },
        range: ->(date) {
          start_of_week = date.beginning_of_week(:monday)
          start_of_week..(start_of_week + 13.days)
        },
        end_date: ->(date) { date.beginning_of_week(:monday) + 13.days }
      },
      "monthly" => {
        shift: ->(date) { date.prev_month.beginning_of_month },
        range: ->(date) { date.beginning_of_month..date.end_of_month },
        end_date: ->(date) { date.end_of_month }
      },
      "quarterly" => {
        shift: ->(date) { date.prev_quarter.beginning_of_quarter },
        range: ->(date) { date.beginning_of_quarter..date.end_of_quarter },
        end_date: ->(date) { date.end_of_quarter }
      },
      "annually" => {
        shift: ->(date) { date.prev_year.beginning_of_year },
        range: ->(date) { date.beginning_of_year..date.end_of_year },
        end_date: ->(date) { date.end_of_year }
      }
    }.freeze

    def initialize(habit)
      @habit = habit
    end

    def calculate
      period_key = @habit.frequency.to_s
      config = PERIODS.fetch(period_key, PERIODS["daily"])
      range_proc = config[:range]
      shift_proc = config[:shift]

      # Check if current period is completed
      if current_period_completed?(range_proc)
        count_streak_from(Date.current, range_proc, shift_proc)
      else
        count_streak_from(shift_proc.call(Date.current), range_proc, shift_proc)
      end
    end

    def calculate_and_save!
      if current_period_incomplete_and_past?
        @habit.reset_streak!
      else
        @habit.update!(streak: calculate)
      end
    end

    private

    def current_period_completed?(range_proc)
      @habit.habit_completions
            .where(completed_on: range_proc.call(Date.current))
            .count >= @habit.target
    end

    def count_streak_from(start_date, range_proc, shift_proc)
      streak = 0
      date = start_date

      # Count consecutive completed periods backwards
      while period_completed?(date, range_proc)
        streak += 1
        date = shift_proc.call(date)
      end

      streak
    end

    def period_completed?(date, range_proc)
      @habit.habit_completions
            .where(completed_on: range_proc.call(date))
            .count >= @habit.target
    end

    def current_period_incomplete_and_past?
      period_key = @habit.frequency.to_s
      config = PERIODS.fetch(period_key, PERIODS["daily"])
      range_proc = config[:range]
      end_date_proc = config[:end_date]

      current_end_date = end_date_proc.call(Date.current)
      completions = @habit.habit_completions
                          .where(completed_on: range_proc.call(Date.current))
                          .count

      Date.current > current_end_date && completions < @habit.target
    end
  end
end
