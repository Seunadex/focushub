module TaskManager
  class Create
    def initialize(user:, params:)
      @user = user
      @params = params
    end

    def call
      task = @user.tasks.build(@params)
      if task.save
        Result.success(task)
      else
        Result.failure(task.errors.full_messages.to_sentence)
      end
    end

    private

    attr_reader :user, :params
  end
end
