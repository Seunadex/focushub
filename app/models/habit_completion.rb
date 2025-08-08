class HabitCompletion < ApplicationRecord
  belongs_to :habit, inverse_of: :habit_completions
  after_commit :update_streak!, on: [ :create, :destroy ]
  after_commit :update_progress!, on: [ :create, :destroy ]

  scope :completed_today, -> { where(completed_on: Date.current) }
  scope :completed_this_week, -> { where(completed_on: Date.current.beginning_of_week..Date.current.end_of_week) }
  scope :completed_this_bi_week, -> { where(completed_on: Date.current.beginning_of_week..(Date.current.end_of_week + 1.week)) }
  scope :completed_this_month, -> { where(completed_on: Date.current.beginning_of_month..Date.current.end_of_month) }
  scope :completed_this_quarter, -> { where(completed_on: Date.current.beginning_of_quarter..Date.current.end_of_quarter) }
  scope :completed_this_year, -> { where(completed_on: Date.current.beginning_of_year..Date.current.end_of_year) }

  validates :habit, presence: true

  validates :completed_on, presence: true
  validate :cannot_complete_in_future

  private

  def cannot_complete_in_future
    if completed_on.present? && completed_on > Date.current
      errors.add(:completed_on, "cannot be in the future")
    end
  end

  private

  def update_streak!
    return unless habit.persisted?
    Habits::StreakCalculator.new(habit).calculate_and_save!
  end

  def update_progress!
    return unless habit.persisted?
    Habits::ProgressCalculator.new(habit).calculate_and_save!
  end
end
