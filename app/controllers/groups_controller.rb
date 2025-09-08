class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group, only: [ :edit, :update, :show, :destroy ]
  before_action :authorize_index!, only: [ :index ]
  before_action :authorize_create!, only: [ :new, :create ]
  before_action :authorize_show!, only: [ :show ]
  before_action :authorize_update!, only: [ :edit, :update ]
  before_action :authorize_destroy!, only: [ :destroy ]

  def index
    @groups = Group
      .left_outer_joins(:group_memberships)
      .where(
        "groups.privacy = :public OR (group_memberships.user_id = :uid AND group_memberships.status = :active)",
        public: Group.privacies[:public_access],
        uid: current_user.id,
        active: GroupMembership.statuses[:active]
      )
      .distinct
  end

  def new
    @group = Group.new
  end

  def edit
  end

  def show
  end

  def update
    if @group.update(group_params)
      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = "Group updated successfully."
          render turbo_stream: [
            turbo_stream.update("modal", ""),
            turbo_stream.prepend("flash", partial: "shared/flash"),
            turbo_stream.replace("group_#{@group.id}", partial: "groups/group", locals: { group: @group })
          ]
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = "Failed to update group."
          render turbo_stream: turbo_stream.replace("modal", partial: "groups/form", locals: { group: @group })
        end
        format.html { render :edit }
      end
    end
  end

  def create
    @group = Group.new(group_params)
    if @group.save
      @group.group_memberships.create!(user: current_user, role: "owner", joined_at: Time.current, status: "active")
      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = "Group created successfully."
          render turbo_stream: [
            turbo_stream.update("modal", ""),
            turbo_stream.prepend("flash", partial: "shared/flash"),
            turbo_stream.update("group_list", partial: "groups/group_list", locals: { groups: Group.all })
          ]
        end
        format.html { redirect_to groups_path, notice: "Group created successfully." }
      end
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = "Failed to create group."
          render turbo_stream: turbo_stream.replace("modal", partial: "groups/form", locals: { group: @group })
        end
        format.html { render :new }
      end
    end
  end

  def destroy
    @group = Group.find(params[:id])
    if @group.destroy
      respond_to do |format|
        format.turbo_stream do
          flash.now[:notice] = "Group deleted successfully."
          render turbo_stream: [
            turbo_stream.update("flash", partial: "shared/flash"),
            turbo_stream.remove("group_#{@group.id}")
          ]
        end
      end
    else
      respond_to do |format|
        format.turbo_stream do
          flash.now[:alert] = "Failed to delete group."
          render turbo_stream: [
            turbo_stream.update("group_#{@group.id}", partial: "groups/group", locals: { group: @group })
          ]
        end
      end
    end
  end

  private

  def group_params
    params.require(:group).permit(:name, :description, :privacy)
  end

  def set_group
    @group = Group.find(params[:id])
  end

  def authorize_index!
    policy = GroupPolicy.new(current_user, nil)
    redirect_to root_path, alert: "You do not have access to this page." unless policy.index?
  end

  def authorize_create!
    policy = GroupPolicy.new(current_user, Group.new)
    redirect_to groups_path, alert: "You do not have permission to create groups." unless policy.create?
  end

  def authorize_show!
    policy = GroupPolicy.new(current_user, @group)
    redirect_to groups_path, alert: "You do not have access to this group." unless policy.show?
  end

  def authorize_update!
    policy = GroupPolicy.new(current_user, @group)
    redirect_to group_path(@group), alert: "You do not have permission to edit this group." unless policy.update?
  end

  def authorize_destroy!
    policy = GroupPolicy.new(current_user, @group)
    redirect_to group_path(@group), alert: "You do not have permission to delete this group." unless policy.destroy?
  end
end
