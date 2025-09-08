class GroupInvitationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  before_action :authorize_inviter!

  def new
    @invitation = @group.group_invitations.new
    @pending = @group.group_invitations.still_valid.order(created_at: :desc)
    @shared_url = invite_url(token: @group.ensure_join_token!)

    respond_to do |format|
      format.turbo_stream { render partial: "group_invitations/form", locals: { group: @group, invitation: @invitation, pending: @pending, shared_url: @shared_url } }
      format.html { render :new, layout: false }
    end
  end

  def create
    email = invitation_params[:invitee_email].to_s.strip.downcase
    if email.present? && @group.group_invitations.still_valid.where("LOWER(invitee_email) = ?", email).exists?
      @invitation = @group.group_invitations.new(invitation_params.merge(inviter: current_user))
      @invitation.errors.add(:invitee_email, "already has a pending invitation.")

      @pending    = @group.group_invitations.still_valid.order(created_at: :desc)
      @shared_url = invite_url(token: @group.ensure_join_token!)

      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = @invitation.errors.full_messages.to_sentence
          render turbo_stream: [
            turbo_stream.prepend("flash", partial: "shared/flash"),
            turbo_stream.replace("modal", partial: "form", locals: { group: @group, invitation: @invitation, pending: @pending, shared_url: @shared_url })
          ]
        end
        format.html do
          flash.now[:alert] = @invitation.errors.full_messages.to_sentence
          render :new, status: :unprocessable_entity, layout: false
        end
      end
      return
    end
    @invitation = @group.group_invitations.new(invitation_params.merge(inviter: current_user))
    if @invitation.save
      # Logic to send invitation email will be here
      @pending = @group.group_invitations.still_valid.order(created_at: :desc)
      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = "Invitation sent successfully."
          render turbo_stream: [
            turbo_stream.prepend("pending_invites", partial: "group_invitations/invitation_chip", locals: { invitation: @invitation, group: @group }),
            turbo_stream.prepend("flash", partial: "shared/flash", locals: { notice: "Invitation sent successfully." })
          ]
        end
        format.html { redirect_to group_invitations_path(@group), notice: "Invitation sent successfully." }
      end
    else
      @pending    = @group.group_invitations.still_valid.order(created_at: :desc)
      @shared_url = invite_url(token: @group.ensure_join_token!)

      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = @invitation.errors.full_messages.to_sentence
          render turbo_stream: [
            turbo_stream.prepend("flash", partial: "shared/flash"),
            turbo_stream.replace("modal", partial: "form", locals: { group: @group, invitation: @invitation, pending: @pending, shared_url: @shared_url })
          ]
        end
        format.html do
          flash.now[:alert] = @invitation.errors.full_messages.to_sentence
          render :new, status: :unprocessable_entity, layout: false
        end
      end
    end
  end

  def destroy
    invitation = @group.group_invitations.find(params[:id])
    invitation.update(status: :revoked, revoked_at: Time.current)
    respond_to do |format|
      format.turbo_stream do
        flash.now[:notice] = "Invitation revoked successfully."
        render turbo_stream: [
          turbo_stream.remove("group_invitation_#{invitation.id}"),
          turbo_stream.prepend("flash", partial: "shared/flash")
        ]
      end
      format.html do
        flash[:notice] = "Invitation revoked successfully."
        redirect_to group_invitations_path(@group)
      end
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
