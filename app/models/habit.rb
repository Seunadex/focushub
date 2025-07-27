class Habit < ApplicationRecord
  belongs_to :user
  has_many :habit_completions, inverse_of: :habit, dependent: :destroy

  validates :title, presence: true
  validates :frequency, presence: true, inclusion: { in: %w[daily weekly bi-weekly monthly quarterly annually], message: "%{value} is not a valid frequency" }

  enum :frequency, { daily: 0, weekly: 1, "bi-weekly": 2, monthly: 3, quarterly: 4, annually: 5 }

  scope :active, -> { where(active: true) }
  scope :archived, -> { where(active: false) }

  def streak
    read_attribute(:streak) || 0
  end

  def active?
    read_attribute(:active) == true
  end

  def archive!
    update!(active: false)
  end

  def restore!
    update!(active: true)
  end

  def completed_today?
    habit_completions.exists?(completed_on: Date.current)
  end

  def complete!(date = Date.current)
    habit_completions.create!(completed_on: date)
    increment!(:streak) if frequency == "daily"
  end

  def reset_streak!
    update(streak: 0)
  end
end
