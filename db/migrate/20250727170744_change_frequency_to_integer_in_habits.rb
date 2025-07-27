class ChangeFrequencyToIntegerInHabits < ActiveRecord::Migration[8.0]
  def change
    change_column_default :habits, :frequency, from: "daily", to: nil
    Habit.where(frequency: nil).update_all(frequency: 0)
    change_column :habits, :frequency, :integer, using: 'frequency::integer'
    change_column_default :habits, :frequency, from: nil, to: 0
    change_column_null :habits, :frequency, false
    add_index :habits, :frequency
  end
end
