class GroupMembership < ApplicationRecord
  belongs_to :user
  belongs_to :group

  validates :role, presence: true
  validates :status, presence: true
  validates :user, presence: true
  validates :group, presence: true
  validates :joined_at, presence: true, on: :create
  validates :left_at, absence: true, if: -> { status != "left" }
  validates :last_read_at, presence: true, on: :update

  enum :role, { member: 0, admin: 1, owner: 2 }
  enum :status, { active: 0, left: 1, invited: 2, removed: 3 }
end
