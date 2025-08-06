module HabitsHelper
  include Pagy::Backend

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

  def active_habit_list
    pagy, habits = pagy(current_user.habits.active.order(created_at: :desc))
    render partial: "dashboard/habit_list", locals: { habits: habits, pagy: pagy }
  end

  # Returns the habit with the best streak for each frequency as a hash
  def best_streaks
    current_user_habits = current_user.habits.active
    {
      daily: current_user_habits.where(frequency: :daily).order(streak: :desc).first,
      weekly: current_user_habits.where(frequency: :weekly).order(streak: :desc).first,
      bi_weekly: current_user_habits.where(frequency: :bi_weekly).order(streak: :desc).first,
      monthly: current_user_habits.where(frequency: :monthly).order(streak: :desc).first,
      quarterly: current_user_habits.where(frequency: :quarterly).order(streak: :desc).first,
      annually: current_user_habits.where(frequency: :annually).order(streak: :desc).first
    }
  end
end
