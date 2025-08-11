class Activity < ApplicationRecord
  belongs_to :user
  belongs_to :group
  belongs_to :subject, polymorphic: true

  validates :kind, presence: true
  validates :user_id, presence: true
  validates :group_id, presence: true
  validates :subject_type, presence: true
  validates :subject_id, presence: true

  enum :kind, { created: 0, updated: 1, deleted: 2 }
end
