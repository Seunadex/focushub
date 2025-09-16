require 'rails_helper'

RSpec.describe "HomeController", type: :request do
  let(:user) { create(:user) }
  context "when unauthenticated" do
    it "renders home for guest" do
      get unauthenticated_root_path
      expect(response).to have_http_status(:ok)
    end
  end

  context "when authenticated" do
    before { sign_in(user, scope: :user) }
    it "renders dashboard for signed-in user via root" do
      get root_path
      expect(response).to have_http_status(:ok)
    end
  end
end
