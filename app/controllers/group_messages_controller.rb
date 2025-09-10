class GroupMessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_group
  # before_action :authorize_user!

  def index
    @group_messages = @group.group_messages.includes(:user).order(created_at: :asc).limit(50)
  end

  def create
    @message = @group.group_messages.new(message_params.merge(user: current_user))

    if @message.save
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to group_path(@group) }
      end
    else
      render index, status: :unprocessable_entity
    end
  end

  private

  def set_group
    @group = Group.find(params[:group_id])
  end

  def message_params
    params.require(:group_message).permit(:body, :thread_id, metadata: {})
  end

  # def authorize_user!
  #   unless @group.users.include?(current_user)
  #     redirect_to dashboard_path, alert: "You are not authorized to access this group."
  #   end
  # end
end
