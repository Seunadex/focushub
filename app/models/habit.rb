class Habit < ApplicationRecord
  belongs_to :user
  has_many :habit_completions, inverse_of: :habit, dependent: :destroy

  validates :title, presence: true
  validates :target, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :frequency, presence: true, inclusion: { in: %w[daily weekly bi-weekly monthly quarterly annually], message: "%{value} is not a valid frequency" }

  enum :frequency, { daily: 0, weekly: 1, "bi-weekly": 2, monthly: 3, quarterly: 4, annually: 5 }

  scope :active, -> { where(active: true) }
  scope :archived, -> { where(active: false) }

  def active?
    read_attribute(:active) == true
  end

  def archived?
    read_attribute(:active) == false
  end

  def archive!
    update!(active: false)
  end

  def restore!
    update!(active: true)
  end

  def self.completion_rate
    total_habits = self.active.count
    return 0 if total_habits.zero?

    completed_habits = HabitCompletion.where(completed_on: Date.current).distinct.count(:habit_id)
    (completed_habits.to_f / total_habits * 100).round
  end

  def complete!(date = Date.current)
    habit_completions.create!(completed_on: date)
  end

  def undo_complete!(date = Date.current)
    completion = habit_completions.find_by(completed_on: date)
    return false unless completion
    completion.destroy!
  end

  def reset_streak!
    update(streak: 0)
  end
end
