class CreateActivities < ActiveRecord::Migration[8.0]
  def change
    create_table :activities do |t|
      t.integer :kind
      t.references :user, null: false, foreign_key: true
      t.references :group, null: false, foreign_key: true
      t.references :subject, polymorphic: true, null: false

      t.timestamps
    end

    add_index :activities, [ :user_id, :group_id ]
    add_index :activities, [ :subject_type, :subject_id ]
  end
end
