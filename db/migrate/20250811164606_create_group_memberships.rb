class CreateGroupMemberships < ActiveRecord::Migration[8.0]
  def change
    create_table :group_memberships do |t|
      t.integer :role, null: false
      t.integer :status, null: false
      t.datetime :joined_at
      t.datetime :left_at
      t.jsonb :notifications
      t.datetime :last_read_at
      t.integer :inviter_id
      t.references :user, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true

      t.timestamps
    end

    add_index :group_memberships, [ :user_id, :group_id ], unique: true
    add_index :group_memberships, :role
    add_index :group_memberships, :status
    add_index :group_memberships, :inviter_id
  end
end
