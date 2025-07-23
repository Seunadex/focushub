class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, only: [ :edit, :update, :destroy, :show, :complete ]
  def index
    @pagy, @tasks = pagy(current_user.tasks.order(due_date: :desc))
  end

  def new
    @task = Task.new
  end

  def create
    @task = current_user.tasks.build(task_params)
    if @task.save
      @pagy, @tasks = paginated_tasks
      flash.now[:notice] = "Task created successfully."
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to tasks_path, notice: "Task created successfully." }
      end
    else
      flash.now[:alert] = @task.errors.full_messages.to_sentence
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
    if @task.update(task_params)
      respond_to do |format|
        flash.now[:notice] = "Task updated successfully."
        format.turbo_stream
        format.html { redirect_to tasks_path, notice: "Task updated successfully." }
      end
    else
      render :edit
    end
  end

  def destroy
    @task.destroy
    @pagy, @tasks = paginated_tasks
    respond_to do |format|
      flash.now[:notice] = "Task deleted successfully."
      format.turbo_stream
      format.html { redirect_to tasks_path, notice: "Task deleted successfully." }
    end
  end

  def complete
    if @task.update(completed: params[:completed], completed_at: params[:completed] ? Time.current : nil)
      respond_to do |format|
        flash.now[:notice] = params[:completed] ? "Good work!, Task completed successfully." : "Task marked as incomplete."
        format.turbo_stream
        format.html { redirect_to dashboard_path, notice: "Task completed successfully." }
      end
    else
      respond_to do |format|
        flash.now[:alert] = "Error completing task."
        format.turbo_stream { render turbo_stream: turbo_replace_task(@task) }
        format.html { redirect_to tasks_path, alert: "Error completing task." }
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
      page = (tasks.count.to_f / Pagy::DEFAULT[:limit]).ceil
      pagy(tasks, page: page)
    end
  end
end
