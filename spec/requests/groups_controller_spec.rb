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

  describe "GET /groups/new" do
    it "renders new successfully" do
      get new_group_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /groups index visibility" do
    it "shows public and member groups, hides others" do
      public_group = create(:group, name: "Public G")
      member_group = create(:group, name: "Member G", privacy: :private_access)
      other_private = create(:group, name: "Other Private", privacy: :private_access)
      create(:group_membership, user: user, group: member_group)
      create(:group_membership, :left, user: user, group: other_private)

      get groups_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include(public_group.name)
      expect(response.body).to include(member_group.name)
      expect(response.body).not_to include(other_private.name)
    end
  end

  describe "POST /groups" do
    it "creates a group and redirects" do
      params = { group: { name: "New Group", description: "Desc", privacy: "public_access" } }
      expect {
        post groups_path, params: params
      }.to change(Group, :count).by(1)
      expect(response).to redirect_to(groups_path)
    end

    it "creates via turbo stream with success" do
      headers = { "ACCEPT" => "text/vnd.turbo-stream.html" }
      expect {
        post groups_path, params: { group: { name: "TS Group", description: "D", privacy: "public_access" } }, headers: headers
      }.to change(Group, :count).by(1)
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("turbo-stream")
    end

    it "fails with invalid params (HTML)" do
      expect {
        post groups_path, params: { group: { name: "", description: "Bad", privacy: "public_access" } }
      }.not_to change(Group, :count)
      expect(response).to have_http_status(:ok)
    end
  end

  describe "GET /groups/:id" do
    context "as member" do
      before { create(:group_membership, :owner, user: user, group: group) }

      it "shows the group" do
        get group_path(group)
        expect(response).to have_http_status(:ok)
      end
    end

    context "as non-member for public group" do
      it "redirects with access alert" do
        get group_path(group)
        expect(response).to redirect_to(groups_path)
        expect(flash[:alert]).to match(/Click join to view group/i)
      end
    end

    context "as non-member for private group" do
      let!(:private_group) { create(:group, privacy: :private_access) }

      it "redirects with private alert" do
        get group_path(private_group)
        expect(response).to redirect_to(groups_path)
        expect(flash[:alert]).to match(/This group is private/i)
      end
    end
  end

  describe "GET /groups/:id/edit" do
    context "as owner" do
      before { create(:group_membership, :owner, user: user, group: group) }

      it "renders edit successfully" do
        get edit_group_path(group)
        expect(response).to have_http_status(:ok)
      end
    end

    context "as non-owner" do
      let!(:not_owned_group) { create(:group, privacy: :public_access) }
      let!(:membership) { create(:group_membership, user: user, group: not_owned_group) }

      it "redirects with alert" do
        get edit_group_path(not_owned_group)
        expect(response).to redirect_to(group_path(not_owned_group))
        expect(flash[:alert]).to match(/do not have permission to edit/i)
      end
    end
  end

  describe "PATCH /groups/:id" do
    let(:headers) { { "ACCEPT" => "text/vnd.turbo-stream.html" } }

    before { create(:group_membership, :owner, user: user, group: group) }

    it "updates the group via turbo stream" do
      patch group_path(group), params: { group: { name: "Updated Name" } }, headers: headers
      expect(response).to have_http_status(:ok)
      expect(group.reload.name).to eq("Updated Name")
    end

    it "fails to update with invalid params via turbo stream" do
      original = group.name
      patch group_path(group), params: { group: { name: "" } }, headers: headers
      expect(response).to have_http_status(:ok)
      expect(group.reload.name).to eq(original)
    end

    it "allows admin to update" do
      membership = GroupMembership.find_by(user: user, group: group)
      membership.update!(role: :admin, last_read_at: Time.current)
      patch group_path(group), params: { group: { description: "Admin updated" } }, headers: headers
      expect(response).to have_http_status(:ok)
      expect(group.reload.description).to eq("Admin updated")
    end
  end

  describe "DELETE /groups/:id" do
    let(:headers) { { "ACCEPT" => "text/vnd.turbo-stream.html" } }

    before { create(:group_membership, :owner, user: user, group: group) }

    it "destroys the group via turbo stream" do
      delete group_path(group), headers: headers
      expect(response).to have_http_status(:ok)
      expect(Group.exists?(group.id)).to be_falsey
    end

    it "rejects unauthorized destroy via turbo stream" do
      other = create(:group, privacy: :public_access)
      delete group_path(other), headers: headers
      expect(response).to have_http_status(:ok)
      expect(Group.exists?(other.id)).to be_truthy
      expect(response.body).to include("turbo-stream")
    end

    it "rejects unauthorized destroy via HTML redirect" do
      other = create(:group, privacy: :public_access)
      delete group_path(other)
      expect(response).to redirect_to(groups_path)
      expect(flash[:alert]).to match(/do not have permission to delete/i)
      expect(Group.exists?(other.id)).to be_truthy
    end
  end

  describe "POST /groups/:id/rotate_join_token" do
    before do
      create(:group_membership, :owner, user: user, group: group)
      group.ensure_join_token!
    end

    it "rotates the join token and redirects" do
      old_token = group.join_token
      post rotate_join_token_group_path(group)
      expect(response).to redirect_to(group_path(group))
      expect(group.reload.join_token).to be_present
      expect(group.join_token).not_to eq(old_token)
    end

    it "rotates the join token via turbo stream" do
      old_token = group.join_token
      headers = { "ACCEPT" => "text/vnd.turbo-stream.html" }
      post rotate_join_token_group_path(group), headers: headers
      expect(response).to have_http_status(:ok)
      expect(group.reload.join_token).to be_present
      expect(group.join_token).not_to eq(old_token)
      expect(response.body).to include("turbo-stream")
    end
  end
end
