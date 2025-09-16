class CreateGroupMessages < ActiveRecord::Migration[8.0]
  def change
    create_table :group_messages do |t|
      t.text :body, null: false
      t.references :user, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true
      t.bigint :thread_id
      t.jsonb :metadata, default: {}, null: false

      t.timestamps
    end
    add_index :group_messages, :thread_id
    add_index :group_messages, [ :group_id, :created_at ]
  end
end
