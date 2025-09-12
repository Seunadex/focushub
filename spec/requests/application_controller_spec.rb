require 'rails_helper'

RSpec.describe 'ApplicationController', type: :request do
  let(:user) { create(:user) }

  describe 'storing location and redirect after sign-in' do
    it 'stores last GET path and redirects there after login' do
      # Visit a protected page while unauthenticated
      get groups_path

      # Location should be stored for Devise to use after sign-in
      expect(session['user_return_to']).to eq(groups_path)

      # Sign in via Devise and expect redirect to stored location
      post user_session_path, params: { user: { email: user.email, password: 'password123' } }
      expect(response).to redirect_to(groups_path)
    end
  end

  describe 'storable_location? guard conditions' do
    it 'does not store location for Devise pages' do
      get new_user_session_path
      expect(session['user_return_to']).to be_nil
    end

    it 'does not store location for XHR requests' do
      get groups_path, headers: { 'HTTP_X_REQUESTED_WITH' => 'XMLHttpRequest' }
      expect(session['user_return_to']).to be_nil
    end

    it 'does not store location for non-GET requests' do
      post groups_path
      expect(session['user_return_to']).to be_nil
    end
  end
end
