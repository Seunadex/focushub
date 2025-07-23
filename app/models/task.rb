class Task < ApplicationRecord
  after_create_commit { broadcast_prepend_to "tasks" }
  after_update_commit { broadcast_replace_to "tasks" }
  after_destroy_commit { broadcast_remove_to "tasks" }

  belongs_to :user

  validates :title, presence: true, length: { maximum: 100 }
  validates :due_date, :priority, presence: true
  validates :priority, inclusion: { in: %w[low medium high], message: "%{value} is not a valid priority" }

enum :priority, { low: 0, medium: 1, high: 2 }

scope :completed, -> { where(completed: true) }
scope :completed_today, -> { where(completed: true, due_date: Date.current) }
scope :due_today, -> { where(due_date: Date.current) }


  # def completed?
  #   completed && completed_at.present?
  # end
  #
  def overdue?
    due_date.present? && due_date < Date.today && !completed
  end
end
