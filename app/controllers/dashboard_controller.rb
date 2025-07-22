class DashboardController < ApplicationController
  before_action :authenticate_user!
  def show
    @current_tasks_count = current_user.tasks.today.count
    @completed_tasks_count = current_user.tasks.completed_today.count
    @pagy, @current_tasks = pagy(current_user.tasks.where(due_date: Date.today).order(due_date: :desc))
  end
end
