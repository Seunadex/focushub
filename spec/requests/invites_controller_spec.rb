require 'rails_helper'

RSpec.describe "InvitesController", type: :request do
  let(:group) { create(:group) }
  let(:inviter) { create(:user) }
  let(:invitee) { create(:user) }

  describe "GET /invites/:token" do
    it "shows invitation when token matches invitation" do
      invitation = create(:group_invitation, group: group, inviter: inviter, invitee_email: invitee.email)
      get invite_path(token: invitation.token)
      expect(response).to have_http_status(:ok)
    end

    it "redirects for invalid token" do
      get invite_path(token: "nope")
      expect(response).to have_http_status(:not_found)
      expect(flash[:alert]).to be_present
    end
  end

  describe "POST /invites/:token/accept" do
    it "accepts valid invitation and joins group" do
      invitation = create(:group_invitation, group: group, inviter: inviter, invitee_email: invitee.email)
      sign_in invitee
      post accept_invitation_path(token: invitation.token)
      expect(response).to redirect_to(group_path(group))
      expect(group.reload.member?(invitee)).to be true
      expect(invitation.reload.accepted?).to be true
    end
  end

  describe "POST /invites/:token/join" do
    it "joins group via share token" do
      token = group.ensure_join_token!
      sign_in invitee
      post join_group_path(token: token)
      expect(response).to redirect_to(group_path(group))
      expect(group.reload.member?(invitee)).to be true
    end
  end
end
