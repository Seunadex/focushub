module TaskManager
  class Update
    def initialize(task:, params:)
      @task = task
      @params = params
    end

    def call
      if @task.update(@params)
        Result.success(@task)
      else
        Result.failure(@task.errors.full_messages.to_sentence)
      end
    end

    private

    attr_reader :task, :params
  end
end
