class AddJoinTokenToGroups < ActiveRecord::Migration[8.0]
  def change
    add_column :groups, :join_token, :string
    add_index :groups, :join_token, unique: true
  end
end
