class HabitsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_habit, only: [ :archive_toggle ]

  def index
    habits = current_user.habits
    habits = habits.active if params[:active] == "true"
    habits = habits.archived if params[:active] == "false"
    habits = habits.order(created_at: :desc)
    @pagy, @habits = pagy(habits, limit: 15)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("habit_list_content", partial: "habits/habit_list", locals: { habits: @habits, pagy: @pagy, page: "" })
      end
      format.html
    end
  end

  def new
    @habit = Habit.new
  end

  def create
    @habit = current_user.habits.build(habit_params)
    if @habit.save
      @habits = current_user.habits.order(created_at: :desc)
      flash.now[:notice] = "Habit created successfully."
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to habits_path, notice: "Habit created successfully." }
      end
    else
      flash.now[:alert] = @habit.errors.full_messages.to_sentence
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("modal", partial: "habits/form", locals: { habit: @habit }) }
        format.html { render :new }
      end
    end
  end

  def archive_toggle
    return unless params[:id].present?
    was_active = @habit.active?
    action = was_active ? "archived" : "restored"
    action_request = was_active ? @habit.archive! : @habit.restore!
    if action_request
      flash[:notice] = "Habit #{action} successfully."
      habits = case was_active
      when true then current_user.habits.active
      when false then current_user.habits.archived
      else current_user.habits
      end
      @pagy, @habits = pagy(habits.order(created_at: :desc), limit: 15)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to habits_path, notice: "Habit #{action} successfully." }
      end
    else
      respond_to do |format|
        flash.now[:alert] = "Failed to #{action} habit."
        format.turbo_stream { render turbo_stream: turbo_stream.update("flash", partial: "shared/flash") }
        format.html { redirect_to habits_path, alert: "Failed to #{action} habit." }
      end
    end
  end

  private

  def habit_params
    params.require(:habit).permit(:title, :description, :frequency, :target)
  end

  def set_habit
    return if params[:id].blank?
    @habit = current_user.habits.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Habit not found."
    redirect_to habits_path
  end
end
