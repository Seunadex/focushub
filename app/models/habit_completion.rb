class HabitCompletion < ApplicationRecord
  belongs_to :habit, inverse_of: :habit_completions
  belongs_to :user
end
