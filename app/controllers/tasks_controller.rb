class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, only: [ :edit, :update, :destroy, :show, :complete ]
  def index
    @tasks = current_user.tasks.order(due_date: :asc)
  end

  def new
    @task = Task.new
  end

  def create
    @task = current_user.tasks.build(task_params)
    if @task.save
      respond_to do |format|
        format.turbo_stream { render turbo_stream: [
          turbo_stream.append("tasks", partial: "tasks/task", locals: { task: @task }),
          turbo_stream.replace("new_task", partial: "tasks/button"),
          turbo_stream.remove("empty_tasks_notice")
        ] }
        format.html { redirect_to tasks_path, notice: "Task created successfully." }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_replace_task(@task) }
        format.html { render :new }
      end
      flash.now[:alert] = "Error creating task. Please fix the errors below."
      @task.errors.add(:base, "Please fix the errors below.")
      flash.now[:alert] = @task.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def show
  end

  def update
    if @task.update(task_params)
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@task, partial: "tasks/task", locals: { task: @task }) }
        format.html { redirect_to tasks_path, notice: "Task updated successfully." }
      end
    else
      render :edit
    end
  end

  def destroy
    @task.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: build_destroy_streams }
      format.html { redirect_to tasks_path, notice: "Task deleted successfully." }
    end
  end

  def complete
    if @task.update(completed: params[:completed])
      if @task.completed
        @task.completed_at ||= Time.current
      else
        @task.completed_at = nil
      end
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_replace_task(@task) }
        format.html { redirect_to dashboard_path, notice: "Task completed successfully." }
      end
    else
      flash[:alert] = "Error completing task."
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_replace_task(@task) }
        format.html { redirect_to tasks_path, alert: "Error completing task." }
      end
    end
  end

  private
  def task_params
    params.require(:task).permit(:title, :due_date)
  end

  def set_task
    @task = current_user.tasks.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Task not found."
  end

  def turbo_replace_task(task)
    turbo_stream.replace(task, partial: "tasks/task", locals: { task: task })
  end

  def build_destroy_streams
    remaining_tasks = params[:source] == "tasks" ? current_user.tasks.where.not(id: @task.id) : current_user.tasks.where(due_date: Date.current)
    streams = [ turbo_stream.remove(@task) ]
    streams << turbo_stream.replace("tasks", partial: "tasks/empty_tasks_notice") if remaining_tasks.empty?
    streams
  end
end
