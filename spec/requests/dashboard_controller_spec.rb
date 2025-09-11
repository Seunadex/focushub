require 'rails_helper'

RSpec.describe "DashboardController", type: :request do
  let(:user) { create(:user) }

  it "renders dashboard for signed-in user" do
    sign_in(user, scope: :user)
    get dashboard_path
    expect(response).to have_http_status(:ok)
  end
end
