class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group, only: [ :edit, :update, :show, :destroy ]
  before_action :authorize_index!, only: [ :index ]
  before_action :authorize_create!, only: [ :new, :create ]
  before_action :authorize_show!, only: [ :show ]
  before_action :authorize_update!, only: [ :edit, :update ]
  before_action :authorize_destroy!, only: [ :destroy ]

  def index
    set_groups
  end

  def new
    @group = Group.new
  end

  def edit
  end

  def show
  end

  def update
    result = Groups::Update.call(group: @group, params: group_params)
    if result.success?
      respond_to do |format|
        format.turbo_stream { flash.now[:notice] = "Group updated successfully."; render :update_success }
      end
    else
      respond_to do |format|
        format.turbo_stream { flash.now[:alert] = "Failed to update group."; render :update_failure }
        format.html { render :edit }
      end
    end
  end

  def create
    result = Groups::Create.call(params: group_params, creator: current_user)
    @group = result.group
    if result.success?
      set_groups
      respond_to do |format|
        format.turbo_stream { flash.now[:notice] = "Group created successfully."; render :create_success }
        format.html { redirect_to groups_path, notice: "Group created successfully." }
      end
    else
      respond_to do |format|
        format.turbo_stream { flash.now[:alert] = "Failed to create group."; render :create_failure }
        format.html { render :new }
      end
    end
  end

  def destroy
    result = Groups::Destroy.call(group: @group)
    if result.success?
      respond_to do |format|
        format.turbo_stream { flash.now[:notice] = "Group deleted successfully."; render :destroy_success }
      end
    else
      respond_to do |format|
        format.turbo_stream { flash.now[:alert] = "Failed to delete group."; render :destroy_failure }
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

  def set_groups
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
    return if policy.show?
    alert_message = @group.public_access? ? "You do not have access to this group. Click join to view group." : "This group is private. Request access to join."
    respond_to do |format|
      format.turbo_stream { flash.now[:alert] = alert_message; render :show }
      format.html { redirect_to groups_path, alert: alert_message }
    end
  end

  def authorize_update!
    policy = GroupPolicy.new(current_user, @group)
    redirect_to group_path(@group), alert: "You do not have permission to edit this group." unless policy.update?
  end

  def authorize_destroy!
    policy = GroupPolicy.new(current_user, @group)
    return if policy.destroy?

    respond_to do |format|
      format.turbo_stream { flash.now[:alert] = "You do not have permission to delete this group."; render :destroy_failure }
      format.html { redirect_to groups_path, alert: "You do not have permission to delete this group." }
    end
  end
end
