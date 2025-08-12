class Group < ApplicationRecord
  has_many :group_memberships, dependent: :destroy
  has_many :users, through: :group_memberships

  validates :name, presence: true
  validates :slug, uniqueness: true, presence: true
  validates :privacy, presence: true

  enum :privacy, { public_group: 0, private_group: 1, secret_group: 2 }

  before_validation :set_slug, on: :create
  before_validation :set_members_count, on: :create

  def role_for(user)
    group_membership = group_memberships.find_by(user: user)
    group_membership&.role || "member"
  end

  private

  def set_slug
    self.slug = name.parameterize if name.present?
  end

  def set_members_count
    self.members_count = 1
  end
end
