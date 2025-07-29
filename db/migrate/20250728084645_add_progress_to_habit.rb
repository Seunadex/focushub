class AddProgressToHabit < ActiveRecord::Migration[8.0]
  def change
    add_column :habits, :progress, :integer, default: 0, null: false
  end
end
