class HabitsController < ApplicationController
  def index
    @habits = current_user.habits.order(created_at: :desc)
    @pagy, @habits = pagy(@habits, limit: 15)

    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace("habit_list_content", partial: "habits/habit_list", locals: { habits: @habits, pagy: @pagy })
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
end
