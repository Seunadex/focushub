class DashboardController < ApplicationController
  before_action :authenticate_user!
  def show
    current_user_tasks = current_user.tasks
    @current_tasks_count = current_user_tasks.due_today.size
    @completed_tasks_count = current_user_tasks.completed_today.size
    @active_habits = current_user.habits.active.order(created_at: :desc)
    @upcoming_tasks = current_user_tasks.due_tomorrow
    @pagy, @current_tasks = paginated_tasks(current_user_tasks.due_today.order(due_date: :asc))
  end

  private

  def paginated_tasks(tasks)
    page  = params[:page].presence || 1
    pagy(tasks, page: page)
  end
end
