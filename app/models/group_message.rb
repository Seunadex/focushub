class GroupMessage < ApplicationRecord
  belongs_to :user
  belongs_to :group

  validates :body, presence: true, length: { maximum: 5000 }

  after_create_commit -> {
    broadcast_append_to(stream_key,
    target: "group_chat_#{group.id}",
    partial: "group_messages/message",
    locals: { message: self })
  }

  def stream_key
    "group_#{group.id}_chat"
  end
end
