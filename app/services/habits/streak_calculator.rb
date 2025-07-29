# app/services/habits/streak_calculator.rb
module Habits
  class StreakCalculator
    def initialize(habit)
      @habit = habit
    end

    # Calculate the current streak based on habit.frequency
    # Returns an integer count of consecutive periods completed.
    def calculate
      case @habit.frequency
      when "daily"
        daily_streak
      when "weekly"
        weekly_streak
      when "bi-weekly"
        bi_weekly_streak
      when "monthly"
        monthly_streak
      when "quarterly"
        quarterly_streak
      when "annually"
        annually_streak
      else
        0
      end
    end

    # Calculate and save the streak back to the habit
    def calculate_and_save!
      @habit.update!(streak: calculate)
    end

    private

    # Count consecutive days with completions, starting from today backwards
    def daily_streak
      streak = 0
      date = Date.current
      while @habit.habit_completions.exists?(completed_on: date)
        streak += 1
        date -= 1
      end
      streak
    end

    # Count consecutive calendar weeks (Mon-Sun) with at least one completion
    def weekly_streak
      streak = 0
      week_start = Date.current.beginning_of_week(:monday)
      while completions_in_week?(week_start)
        streak += 1
        week_start -= 7.days
      end
      streak
    end

    # Count consecutive bi-weekly periods (2 weeks) with at least one completion
    def bi_weekly_streak
      streak = 0
      week_start = Date.current.beginning_of_week(:monday)
      while completions_in_week?(week_start)
        streak += 1
        week_start -= 14.days
      end
      streak
    end

    # Count consecutive calendar months with at least one completion
    def monthly_streak
      streak = 0
      month_start = Date.current.beginning_of_month
      while completions_in_month?(month_start)
        streak += 1
        month_start = (month_start - 1.day).beginning_of_month
      end
      streak
    end

    def quarterly_streak
      streak = 0
      quarter_start = Date.current.beginning_of_quarter
      while completions_in_month?(quarter_start)
        streak += 1
        quarter_start = (quarter_start - 1.day).beginning_of_quarter
      end
      streak
    end

    def annually_streak
      streak = 0
      year_start = Date.current.beginning_of_year
      while completions_in_month?(year_start)
        streak += 1
        year_start = (year_start - 1.day).beginning_of_year
      end
      streak
    end

    # Helper: checks if any completions exist in the given week period
    def completions_in_week?(week_start)
      week_end = week_start.end_of_week(:sunday)
      @habit.habit_completions.where(completed_on: week_start..week_end).exists?
    end

    # Helper: checks if any completions exist in the given month period
    def completions_in_month?(month_start)
      month_end = month_start.end_of_month
      @habit.habit_completions.where(completed_on: month_start..month_end).exists?
    end
  end
end
