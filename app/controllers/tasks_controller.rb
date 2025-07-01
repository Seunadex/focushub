class TasksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_task, only: [ :edit, :update, :destroy, :show ]
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
          turbo_stream.prepend("tasks", partial: "tasks/task", locals: { task: @task }),
          turbo_stream.replace("new_task", partial: "tasks/button")
        ] }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace(@task, partial: "tasks/form", locals: { task: @task }) }
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
      end
    else
      render :edit
    end
  end

  def destroy
    @task.destroy
    respond_to do |format|
      format.turbo_stream { render turbo_stream: turbo_stream.remove(@task) }
    end
  end

  private
  def task_params
    params.require(:task).permit(:title, :due_date)
  end

  def set_task
    @task ||= current_user.tasks.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "Task not found."
  end
end
