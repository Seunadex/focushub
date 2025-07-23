class CreateHabits < ActiveRecord::Migration[8.0]
  def change
    create_table :habits do |t|
      t.string :title
      t.string :frequency, default: "daily"
      t.text :description
      t.integer :target, default: 1, null: false
      t.integer :streak, default: 0
      t.boolean :active, default: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
