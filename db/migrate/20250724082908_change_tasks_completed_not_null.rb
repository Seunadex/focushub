class ChangeTasksCompletedNotNull < ActiveRecord::Migration[8.0]
  def change
    change_column_default :tasks, :completed, from: nil, to: false
    change_column_null :tasks, :completed, false, default: false
  end
end
