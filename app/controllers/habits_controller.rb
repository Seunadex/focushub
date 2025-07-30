class HabitsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_habit, only: [ :archive_toggle, :complete, :destroy, :edit, :update ]

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

  def edit
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

  def update
    if @habit.update(habit_params)
      respond_to do |format|
        flash.now[:notice] = "Habit updated successfully."
        format.turbo_stream
        format.html { redirect_to habits_path, notice: "Habit updated successfully." }
      end
    else
      flash.now[:alert] = @habit.errors.full_messages.to_sentence
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("modal", partial: "habits/form", locals: { habit: @habit }) }
        format.html { render :edit }
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

  def complete
    return unless params[:id].present?
    completed_status = ActiveModel::Type::Boolean.new.cast(params[:completed])
    completed_action = completed_status ? "complete!" : "undo_complete!"
    if @habit.send(completed_action)
      flash.now[:notice] = completed_status ? "'#{@habit.title}' marked as complete." : "'#{@habit.title}' marked as incomplete."
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to habits_path, notice: flash.now[:notice] }
      end
    end
  end

  def destroy
    return unless params[:id].present?
    if @habit&.destroy
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to habits_path, notice: "Habit deleted successfully." }
      end
    else
      respond_to do |format|
        flash.now[:alert] = "Failed to delete habit."
        format.turbo_stream { render turbo_stream: turbo_stream.update("flash", partial: "shared/flash") }
        format.html { redirect_to habits_path, alert: "Failed to delete habit." }
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
