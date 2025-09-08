class GroupInvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  before_action :authorize_inviter!

  def new
    @invitation = @group.group_invitations.new
    @pending = @group.group_invitations.still_valid.order(created_at: :desc)
    @shared_url = invite_url(token: @group.ensure_join_token!)

    respond_to do |format|
      format.turbo_stream
      format.html { render :new, layout: false }
    end
  end

  def create
    result = GroupInvitations::Create.call(
      group: @group,
      inviter: current_user,
      invitee_email: invitation_params[:invitee_email]
    )

    @invitation = result.invitation

    unless result.success?
      @pending    = @group.group_invitations.still_valid.order(created_at: :desc)
      @shared_url = invite_url(token: @group.ensure_join_token!)
      alert_message = @invitation.errors.full_messages.to_sentence

      respond_to do |format|
        flash.now[:alert] = alert_message
        format.turbo_stream
        format.html { render :new, status: :unprocessable_entity, layout: false }
      end
      return
    end

    notice_message = "Invitation sent successfully."
    respond_to do |format|
      flash.now[:notice] = notice_message
      format.turbo_stream
      format.html { redirect_to group_invitations_path(@group), notice: notice_message }
    end
  end

  def destroy
    result = GroupInvitations::Destroy.call(group: @group, id: params[:id])
    @invitation = result.invitation

    unless result.success?
      alert_message = result.error_message || "Unable to revoke invitation."
      respond_to do |format|
        flash.now[:alert] = alert_message
        format.turbo_stream
        format.html { redirect_to group_invitations_path(@group), alert: alert_message }
      end
      return
    end

    notice_message = "Invitation revoked successfully."
    respond_to do |format|
      flash.now[:notice] = notice_message
      format.turbo_stream
      format.html { redirect_to group_invitations_path(@group), notice: notice_message }
    end
  end

  private

  def set_group
    @group = Group.find(params[:group_id])
  end

  def invitation_params
    params.require(:group_invitation).permit(:invitee_email)
  end

  def authorize_inviter!
    policy = GroupInvitationPolicy.new(current_user, @group)
    unless policy.invite?
      redirect_to group_path(@group), alert: "You do not have permission to invite members to this group."
    end
  end
end
