require 'rails_helper'

RSpec.describe "GroupInvitationsController", type: :request do
  let(:owner) { create(:user) }
  let(:group) { create(:group) }
  let!(:ownership) { create(:group_membership, :owner, user: owner, group: group) }

  before { sign_in(owner, scope: :user) }

  describe "GET /groups/:group_id/group_invitations/new" do
    it "renders new invitation page for authorized user" do
      get new_group_group_invitation_path(group)
      expect(response).to have_http_status(:ok)
    end

    it "rejects unauthorized user" do
      other = create(:user)
      sign_in other
      get new_group_group_invitation_path(group)
      expect(response).to redirect_to(group_path(group))
      expect(flash[:alert]).to match(/do not have permission/i)
    end
  end

  describe "POST /groups/:group_id/group_invitations" do
    let(:invitee) { create(:user) }

    it "creates an invitation and redirects with notice" do
      expect {
        post group_group_invitations_path(group), params: { group_invitation: { invitee_email: invitee.email } }
      }.to change(GroupInvitation, :count).by(1)

      expect(response).to have_http_status(:redirect)
      expect(flash[:notice]).to eq("Invitation sent successfully.")
    end

    it "fails with invalid email and renders unprocessable" do
      post group_group_invitations_path(group), params: { group_invitation: { invitee_email: "invalid" } }
      expect(response).to have_http_status(:unprocessable_content)
      expect(flash.now[:alert] || flash[:alert]).to be_present
    end
  end

  describe "DELETE /groups/:group_id/group_invitations/:id" do
    let(:invitee) { create(:user) }
    let!(:invitation) { create(:group_invitation, group: group, inviter: owner, invitee_email: invitee.email) }

    it "revokes the invitation and redirects with notice" do
      delete group_group_invitation_path(group, invitation)
      expect(response).to have_http_status(:redirect)
      expect(flash[:notice]).to eq("Invitation revoked successfully.")
      expect(invitation.reload.revoked?).to be true
    end

    it "handles missing invitation with alert" do
      delete group_group_invitation_path(group, 0)
      expect(response).to have_http_status(:redirect)
      expect(flash[:alert]).to eq("Invitation not found.")
    end
  end
end
