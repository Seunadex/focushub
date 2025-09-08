class InvitesController < ApplicationController
  before_action :authenticate_user!, only: :accept

  def show
    @invitation = GroupInvitation.still_valid.find_by(token: params[:token])
    # puts "============START=================="
    # puts params[:token]
    # puts "============END=================="
    if @invitation
      @group = @invitation.group
      return render :show
    end

    if @group.present?
      render :share_link
    else
      redirect_to root_path, alert: "Invalid or expired invitation link.", status: :not_found
    end
  end

  def accept
    if (inv = GroupInvitation.still_valid.find_by(token: params[:token]))
      puts "============START=================="
      @group = inv.group
      add_member!(current_user, @group)
      inv.mark_accepted!
      redirect_to group_path(@group), notice: "You have successfully joined the group."
    end

    if (group = Group.find_by(join_token: params[:token]))
      puts "============END=================="
      add_member!(current_user, group)
      redirect_to group_path(group), notice: "You have successfully joined the group."
    end
  rescue ActiveRecord::RecordInvalid => e
    redirect_to root_path, alert: "Failed to accept the invitation: #{e.message}"
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
