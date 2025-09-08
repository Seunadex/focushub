class GroupInvitation < ApplicationRecord
  belongs_to :group
  belongs_to :inviter, class_name: "User"
  belongs_to :invitee, class_name: "User", optional: true

  enum :status, { pending: 0, accepted: 1, revoked: 2, expired: 3 }

  before_validation :set_defaults, on: :create
  validates :token, presence: true, uniqueness: true
  validates :invitee_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }, unless: -> { invitee_id.present? }
  validate :validate_invitee_email, on: :create

  scope :still_valid, -> { pending.where("expires_at IS NULL OR expires_at > ?", Time.current) }

  def expired?
    expires_at.present? && Time.current > expires_at
  end

  def mark_accepted!
    return if accepted? || revoked? || expired?

    update!(status: :accepted, accepted_at: Time.current)
  end

  private

  def validate_invitee_email
    errors.add(:invitee_email, "can't be blank") if invitee_email.blank?
    errors.add(:invitee_email, "not found") unless User.exists?(email: invitee_email)
    if invitee_email.present? && group.member?(User.find_by(email: invitee_email))
      errors.add(:invitee_email, "is already a member of this group.")
    end
  end

  def set_defaults
    self.token ||= SecureRandom.urlsafe_base64(24)
    self.expires_at ||= 7.days.from_now
  end
end
