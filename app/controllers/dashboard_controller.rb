class DashboardController < ApplicationController
  before_action :authenticate_user!
  before_action :set_current_user_tasks, only: [ :show ]
  def show
    @current_tasks_count = @current_user_tasks.due_today.size
    @completed_tasks_count = @current_user_tasks.completed_today.size

    tasks_page = params[:tasks_page].presence&.to_i || 1
    habits_page = params[:habits_page].presence&.to_i || 1

    @habit_pagy, @active_habits = pagy(
      current_user.habits.active.order(created_at: :desc),
      page: habits_page
    )
    @task_pagy, @current_tasks = pagy(
      @current_user_tasks.due_today.order(due_date: :asc),
      page: tasks_page
    )

    @upcoming_tasks = @current_user_tasks.due_tomorrow
  end

  private

  def set_current_user_tasks
    @current_user_tasks = current_user.tasks
  end
end
