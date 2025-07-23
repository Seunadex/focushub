class DashboardController < ApplicationController
  before_action :authenticate_user!
  def show
    @current_tasks_count = current_user.tasks.due_today.size
    @completed_tasks_count = current_user.tasks.completed_today.size
    @pagy, @current_tasks = pagy(current_user.tasks.due_today.order(due_date: :desc))
  end
end
