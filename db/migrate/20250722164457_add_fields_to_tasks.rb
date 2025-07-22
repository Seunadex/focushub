class AddFieldsToTasks < ActiveRecord::Migration[8.0]
  def change
    add_column :tasks, :priority, :integer, default: 0, null: false
    add_column :tasks, :description, :string

    add_index :tasks, :priority
    add_index :tasks, [ :user_id, :due_date ]
    add_index :tasks, [ :user_id, :completed ]
    add_index :tasks, [ :user_id, :priority ]
  end
end
