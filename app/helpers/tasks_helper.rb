module TasksHelper
  include Pagy::Backend

  def dashboard_task_list
    @pagy, @tasks = pagy(current_user.tasks.due_today.order(due_date: :asc))
    render partial: "dashboard/task_list", locals: { tasks: @tasks, pagy: @pagy }
  end
end
