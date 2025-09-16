module Habits
  class ToggleArchive
    def initialize(habit:)
      @habit = habit
    end

    def call
      was_active = @habit.active?
      action = was_active ? :archived : :restored

      if was_active ? @habit.archive! : @habit.restore!
        Result.success({ was_active: was_active, action: action.to_s })
      else
        Result.failure("Failed to #{action} habit.")
      end
    rescue => e
      Result.failure(e.message)
    end

    private

    attr_reader :habit
  end
end
