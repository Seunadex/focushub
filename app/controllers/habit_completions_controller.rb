class HabitCompletionsController < ApplicationController
  before_action :set_habit

  def undo
    if @habit.habit_completions.order(created_at: :desc).last&.destroy!
      respond_to do |format|
        flash.now[:notice] = "Last habit completion undone!"
        format.turbo_stream { render turbo_stream: [ turbo_stream.update("flash", partial: "shared/flash"), turbo_stream.update("habit_#{@habit.id}", partial: "habits/habit", locals: { habit: @habit }) ] }
        format.html { redirect_to root_path, notice: "Habit completion undone!" }
      end
    else
      respond_to do |format|
        flash.now[:alert] = "Habit completion not found!"
        format.turbo_stream { render turbo_stream: [ turbo_stream.update("flash", partial: "shared/flash") ] }
        format.html { redirect_to root_path, alert: "Habit completion not found!" }
      end
    end
  end

  private

  def set_habit
    @habit = Habit.find(params[:habit_id])
  end
end
