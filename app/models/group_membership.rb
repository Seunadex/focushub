class GroupMembership < ApplicationRecord
  belongs_to :user
  belongs_to :group, counter_cache: :members_count

  validates :role, presence: true
  validates :status, presence: true
  validates :user, presence: true
  validates :group, presence: true
  validates :joined_at, presence: true, on: :create
  validates :left_at, absence: true, if: -> { status != "left" }
  validates :last_read_at, presence: true, on: :update

  enum :role, { member: 0, admin: 1, owner: 2 }
  enum :status, { active: 0, left: 1, invited: 2, removed: 3 }

  after_update :recount_on_status_change
  after_destroy :dec_members_count_if_became_inactive

  private

  def active_now?
    saved_change_to_status? && status == "active"
  end

  def became_inactive?
    saved_change_to_status? && status_before_last_save == "active" && status != "active"
  end

  def dec_members_count_if_became_inactive
    group.decrement!(:members_count) if became_inactive?
  end

  def recount_on_status_change
    return unless active_now? || became_inactive?

    group.update!(members_count: group.group_memberships.where(status: "active").count)
  end
end
