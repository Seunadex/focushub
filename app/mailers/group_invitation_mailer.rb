class GroupInvitationMailer < ApplicationMailer
  def invite
    @invitation = params[:invitation]
    @group = @invitation.group
    @inviter = @invitation.inviter
    @accept_url = invite_url(@invitation.token)
    mail to: @invitation.invitee_email, subject: "#{@inviter.first_name} has invited you to join the group #{@group.name}"
  end
end
