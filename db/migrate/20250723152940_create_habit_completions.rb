class CreateHabitCompletions < ActiveRecord::Migration[8.0]
  def change
    create_table :habit_completions do |t|
      t.references :habit, null: false, foreign_key: true
      t.date :completed_on, null: false
      t.timestamps
    end
  end
end
