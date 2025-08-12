class GroupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group, only: [ :edit, :update ]

  def index
    @groups = Group.all
  end

  def new
    @group = Group.new
  end

  def edit
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
end
