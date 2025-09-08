class Group < ApplicationRecord
  has_many :group_memberships, dependent: :destroy
  has_many :users, through: :group_memberships
  has_many :group_invitations, dependent: :destroy

  validates :name, presence: true
  validates :slug, uniqueness: true, presence: true
  validates :privacy, presence: true

  enum :privacy, { public_access: 0, private_access: 1 }

  before_validation :set_slug, on: :create

  def ensure_join_token!
    return join_token if join_token.present?

    update!(join_token: SecureRandom.urlsafe_base64(24))
    join_token
  end

  def rotate_join_token
    update!(join_token: SecureRandom.urlsafe_base64(24))
  end

  def role_for(user)
    group_membership = group_memberships.find_by(user: user)
    group_membership&.role || "member"
  end

  def owned_by?(user)
    group_memberships.exists?(user: user, role: "owner")
  end

  def member?(user)
    group_memberships.exists?(user: user, status: "active")
  end

  private

  def set_slug
    self.slug = name.parameterize if name.present?
  end
end
