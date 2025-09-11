class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, only: [ :edit, :update, :destroy, :show, :complete ]
  def index
    tasks = current_user.tasks
    tasks = tasks.pending if params[:status] == "pending"
    tasks = tasks.completed if params[:status] == "completed"
    tasks = tasks.where("LOWER(title) LIKE ?", "%#{params[:search].downcase}%") if params[:search].present?
    tasks = tasks.where(priority: params[:priority]) if params[:priority].present?

    @pagy, @tasks = pagy(tasks.order(due_date: :desc))
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.update("task_list_content", partial: "tasks/task_list", locals: { tasks: @tasks, pagy: @pagy, source: params[:status] })
      end
      format.html
    end
  end

  def new
    @task = Task.new
  end

  def create
    result = TaskManager::Create.new(user: current_user, params: task_params).call
    if result.success?
      @task = result.value
      @pagy, @tasks = pagy(current_user.tasks.order(due_date: :desc))
      flash.now[:notice] = "Task created successfully."
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to tasks_path, notice: "Task created successfully." }
      end
    else
      @task = result.value || Task.new(task_params)
      flash.now[:alert] = result.error
      respond_to do |format|
        format.html { render :new }
      end
    end
  end

  def edit
  end

  def show
  end


  # On task update
  # Update the task list in the dashboard and tasks page
  # Update the upcoming tasks section in the dashboard if date changed
  # Update the high priority, pending, completed task count in the task page (Done)
  # remove modal
  # Update the task in the tasks page
  def update
    result = TaskManager::Update.new(task: @task, params: task_params).call
    if result.success?
      respond_to do |format|
        flash.now[:notice] = "Task updated successfully."
        format.turbo_stream
        format.html { redirect_to tasks_path, notice: "Task updated successfully." }
      end
    else
      flash.now[:alert] = result.error
      render :edit
    end
  end

  def destroy
    result = TaskManager::Destroy.new(task: @task).call
    respond_to do |format|
      if result.success?
        source = params[:source] || ""
        tasks = case source
        when "dashboard"
          current_user.tasks.due_today.order(due_date: :desc)
        when "pending"
          current_user.tasks.pending.order(due_date: :desc)
        when "completed"
          current_user.tasks.completed.order(due_date: :desc)
        else
          current_user.tasks.order(due_date: :desc)
        end

        page = [ (tasks.size.to_f / Pagy::DEFAULT[:limit]).ceil, 1 ].max
        @pagy, @tasks = pagy(tasks, page: page)
        @source = source

        flash.now[:notice] = "Task deleted successfully."
      else
        flash.now[:alert] = result.error
      end
      format.turbo_stream
      format.html { redirect_to tasks_path, notice: flash.now[:notice] }
    end
  end

  def complete
    result = TaskManager::Complete.new(task: @task, completed: params[:completed]).call

    respond_to do |format|
      if result.success?
        # Update the task list based on the source
        source = params[:source] || ""
        tasks = case source
        when "dashboard"
          current_user.tasks.due_today
        when "pending"
          current_user.tasks.pending.where.not(id: @task.id)
        when "completed"
          current_user.tasks.completed.where.not(id: @task.id)
        else
          current_user.tasks.where.not(id: @task.id)
        end

        page = [ (tasks.size.to_f / Pagy::DEFAULT[:limit]).ceil, 1 ].max
        @pagy, @tasks = pagy(tasks.order(due_date: :desc), page: page)
        @source = source

        flash.now[:notice] = params[:completed] == "true" ? "Good work!, Task completed successfully." : "Task marked as incomplete."
        format.turbo_stream
        format.html { redirect_to dashboard_path, notice: flash.now[:notice] }
      else
        flash.now[:alert] = result.error
        format.turbo_stream { render turbo_stream: turbo_replace_task(@task) }
        format.html { redirect_to tasks_path, alert: result.error }
      end
    end
  end

  private
  def task_params
    params.require(:task).permit(:title, :due_date, :description, :priority)
  end

  def set_task
    @task = current_user.tasks.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash.now[:alert] = "Task not found."
  end

  def turbo_replace_task(task)
    turbo_stream.replace(task, partial: "tasks/task", locals: { task: task })
  end

  def remaining_tasks
    referer_path = URI(request.referer || "").path
    referer_path.include?("tasks") ? current_user.tasks.where.not(id: @task.id).order(due_date: :desc) : current_user.tasks.due_today.order(due_date: :asc)
  end

  def paginated_tasks
    @paginated_tasks ||= begin
      tasks = remaining_tasks
      page_count = (tasks.size.to_f / Pagy::DEFAULT[:limit]).ceil
      # TODO: REcheck this logic
      page = [ page_count, 1 ].max
      pagy(tasks, page: page)
    end
  end
  # def paginated_tasks
  #   tasks = remaining_tasks
  #   page  = params[:page].presence || 1
  #   pagy(tasks, page: page)
  # end
end
