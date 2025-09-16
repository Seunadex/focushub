class InvitesController < ApplicationController
  before_action :authenticate_user!, only: [ :accept_invitation, :join_group ]

  def show
    @invitation = GroupInvitation.still_valid.find_by(token: params[:token])
    if @invitation
      @group = @invitation.group
      render :show
    elsif (@group = Group.find_by(join_token: params[:token]))
      render :share_link
    else
      redirect_to root_path, alert: "Invalid or expired invitation link.", status: :not_found
    end
  end

  def accept_invitation
    inv = GroupInvitation.still_valid.find_by(token: params[:token])

    unless inv
      redirect_to root_path, alert: "Invalid or expired invitation."
      return
    end

    @group = inv.group
    add_member!(current_user, @group)
    inv.mark_accepted!
    redirect_to group_path(@group), notice: "You have successfully joined the group."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to root_path, alert: "Failed to accept the invitation: #{e.message}"
  end

  def join_group
    group = Group.find_by(join_token: params[:token])

    unless group
      redirect_to root_path, alert: "Invalid join token."
      return
    end

    add_member!(current_user, group)

    respond_to do |format|
      format.turbo_stream {
        redirect_to group_path(group),
        notice: "You have successfully joined the group."
      }
      format.html { redirect_to group_path(group), notice: "You have successfully joined the group." }
    end
  rescue ActiveRecord::RecordInvalid => e
    redirect_to root_path, alert: "Failed to join the group: #{e.message}"
  end

  private

  def add_member!(user, group)
    group.group_memberships.find_or_create_by!(user: user) do |membership|
      membership.role = "member"
      membership.status = "active"
      membership.joined_at = Time.current
    end
  end
end
