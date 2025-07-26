class Habit < ApplicationRecord
  belongs_to :user
  has_many :habit_completions, inverse_of: :habit, dependent: :destroy

  validates :title, presence: true
  validates :frequency, presence: true, inclusion: { in: %w[daily weekly monthly], message: "%{value} is not a valid frequency" }

  enum :frequency, { daily: 0, weekly: 1, "bi-weekly": 2, monthly: 3, quarterly: 4, annually: 5 }
end
