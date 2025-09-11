require 'rails_helper'

RSpec.describe "GroupsController", type: :request do
  let(:user) { create(:user) }
  let!(:group) { create(:group, privacy: :public_access) }

  before { sign_in(user, scope: :user) }

  describe "GET /groups" do
    it "returns success" do
      get groups_path
      expect(response).to have_http_status(:ok)
    end
  end
end
