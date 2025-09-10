require 'rails_helper'

RSpec.describe GroupMessage, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:group) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:body) }
    it { is_expected.to validate_length_of(:body).is_at_most(5000) }
  end

  describe "#stream_key" do
    it "returns the group-specific stream key" do
      user = User.create!(email: "tester@example.com", password: "password123")
      group = Group.create!(name: "Testers", privacy: :public_access)
      message = described_class.new(body: "Hello", user: user, group: group)

      expect(message.stream_key).to eq("group_#{group.id}_chat")
    end
  end
end
