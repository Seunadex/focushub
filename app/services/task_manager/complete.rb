module TaskManager
  class Complete
    def initialize(task:, completed:)
      @task = task
      @completed = ActiveModel::Type::Boolean.new.cast(completed)
    end

    def call
      if @task.update(completed: @completed, completed_at: @completed ? Time.current : nil)
        Result.success(@task)
      else
        Result.failure("Error completing task.")
      end
    end

    private

    attr_reader :task, :completed
  end
end
