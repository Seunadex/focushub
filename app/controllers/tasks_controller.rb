class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, only: [ :edit, :update, :destroy, :show, :complete ]
  def index
    tasks = current_user.tasks

    if params[:status] == "pending"
      tasks = tasks.pending
    elsif params[:status] == "completed"
      tasks = tasks.completed
    end

    tasks = tasks.where("title LIKE ?", "%#{params[:search]}%") if params[:search].present?
    tasks = tasks.where(priority: params[:priority]) if params[:priority].present?

    @pagy, @tasks = pagy(tasks.order(due_date: :desc), limit: 15)
  end

  def new
    @task = Task.new
  end

  def create
    result = TaskManager::Create.new(user: current_user, params: task_params).call
    if result.success?
      @task = result.value
      @pagy, @tasks = paginated_tasks
      flash.now[:notice] = "Task created successfully."
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to tasks_path, notice: "Task created successfully." }
      end
    else
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
    @pagy, @tasks = paginated_tasks
    respond_to do |format|
      if result.success?
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
    referer_path.include?("tasks") ? current_user.tasks.where.not(id: @task.id).order(due_date: :desc) : current_user.tasks.where(due_date: Date.current).order(due_date: :desc)
  end

  def paginated_tasks
    @paginated_tasks ||= begin
      tasks = remaining_tasks
      page = (tasks.size.to_f / Pagy::DEFAULT[:limit]).ceil
      pagy(tasks, page: page)
    end
  end
end
