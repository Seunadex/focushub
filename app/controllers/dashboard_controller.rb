class DashboardController < ApplicationController
  before_action :authenticate_user!
  def show
    @pagy, @current_tasks = pagy(current_user.tasks.where(due_date: Date.today).order(due_date: :asc))
  end
end
