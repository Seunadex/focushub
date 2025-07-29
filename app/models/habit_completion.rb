class HabitCompletion < ApplicationRecord
  belongs_to :habit, inverse_of: :habit_completions
  after_commit :update_streak!, on: [ :create, :destroy ]
  after_commit :update_progress!, on: [ :create, :destroy ]

  private

  def update_streak!
    Habits::StreakCalculator.new(habit).calculate_and_save!
  end

  def update_progress!
    Habits::ProgressCalculator.new(habit).calculate_and_save!
  end
end
