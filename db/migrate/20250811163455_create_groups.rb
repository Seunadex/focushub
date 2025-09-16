class CreateGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :groups do |t|
      t.string :name
      t.string :slug
      t.integer :privacy
      t.text :description
      t.jsonb :settings
      t.integer :members_count, default: 0
      t.datetime :archived_at

      t.timestamps
    end

    add_index :groups, :slug, unique: true
    add_index :groups, :privacy
    add_index :groups, :archived_at
  end
end
