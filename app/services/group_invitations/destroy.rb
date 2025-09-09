module GroupInvitations
  class Destroy
    Result = Struct.new(:success?, :invitation, :error_message, keyword_init: true)

    def self.call(group:, id:)
      invitation = group.group_invitations.find_by(id: id)
      return Result.new(success?: false, invitation: nil, error_message: "Invitation not found.") unless invitation

      return Result.new(success?: true, invitation: invitation, error_message: nil) if invitation.revoked?

      if invitation.update(status: :revoked, revoked_at: Time.current)
        Result.new(success?: true, invitation: invitation, error_message: nil)
      else
        Result.new(success?: false, invitation: invitation, error_message: invitation.errors.full_messages.to_sentence)
      end
    end
  end
end
