require 'rails_helper'

RSpec.describe "GroupMessagesController", type: :request do
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let!(:membership) { create(:group_membership, user: user, group: group) }

  before { sign_in(user, scope: :user) }

  describe "GET /groups/:group_id/group_messages" do
    it "returns success" do
      get group_group_messages_path(group)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "POST /groups/:group_id/group_messages" do
    it "creates a message and redirects" do
      expect {
        post group_group_messages_path(group), params: { group_message: { body: "Hello" } }
      }.to change(GroupMessage, :count).by(1)
      expect(response).to have_http_status(:redirect)
    end
  end
end
