module HabitsHelper
  def habit_streak_text(habit)
    streak = habit.streak || 0
    return "No streak data available" if streak.zero?
    case habit.frequency
    when "daily"
      "#{streak} consecutive days"
    when "weekly"
      "#{streak} consecutive weeks"
    when "bi-weekly"
      "#{streak} consecutive bi-weeks"
    when "monthly"
      "#{streak} consecutive months"
    when "quarterly"
      "#{streak} consecutive quarters"
    when "annually"
      "#{streak} consecutive years"
    else
      "No streak data available"
    end
  end
end
