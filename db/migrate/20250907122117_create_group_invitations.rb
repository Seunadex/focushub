class CreateGroupInvitations < ActiveRecord::Migration[8.0]
  def change
    create_table :group_invitations do |t|
      t.references :group, null: false, foreign_key: true
      t.references :inviter, null: false, foreign_key: { to_table: :users }
      t.string :invitee_email, null: false
      t.bigint :invitee_id
      t.string :token, null: false
      t.integer :status, null: false, default: 0
      t.datetime :accepted_at
      t.datetime :revoked_at
      t.datetime :expires_at
      t.jsonb :metadata, null: false, default: {}
      t.timestamps
    end

    add_index :group_invitations, :token, unique: true
    add_index :group_invitations, :invitee_email
    add_index :group_invitations, :invitee_id
  end
end
