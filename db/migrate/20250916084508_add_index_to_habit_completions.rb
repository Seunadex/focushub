class AddIndexToHabitCompletions < ActiveRecord::Migration[8.0]
  def change
    add_index :habit_completions, [ :habit_id, :completed_on ]
  end
end
