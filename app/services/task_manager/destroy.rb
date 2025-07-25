module TaskManager
  class Destroy
    def initialize(task:)
      @task = task
    end

    def call
      if @task.destroy
        Result.success(nil)
      else
        Result.failure("Unable to delete task.")
      end
    end

    private

    attr_reader :task
  end
end
