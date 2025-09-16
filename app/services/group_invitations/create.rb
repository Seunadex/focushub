module GroupInvitations
  class Create
    Result = Struct.new(:success?, :invitation, :error_message, keyword_init: true)

    def self.call(group:, inviter:, invitee_email:)
      email = invitee_email.to_s.strip.downcase

      invitation = group.group_invitations.new(inviter: inviter, invitee_email: email)

      if email.present? && group.group_invitations.still_valid.where("LOWER(invitee_email) = ?", email).exists?
        invitation.errors.add(:invitee_email, "already has a pending invitation.")
        return Result.new(success?: false, invitation: invitation, error_message: invitation.errors.full_messages.to_sentence)
      end

      if invitation.save
        Result.new(success?: true, invitation: invitation, error_message: nil)
      else
        Result.new(success?: false, invitation: invitation, error_message: invitation.errors.full_messages.to_sentence)
      end
    end
  end
end
