require 'rails_helper'

# Specs in this file have access to a helper object that includes
# the GroupsHelper. For example:
#
# describe GroupsHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe GroupsHelper, type: :helper do
  let(:group) { Group.create!(name: "Test Group", privacy: :public_access) }
  let(:user)  { create(:user) }

  describe "#group_role_icon" do
    it "returns 'crown' for owners" do
      create(:group_membership, :owner, group: group, user: user)
      expect(helper.group_role_icon(user, group)).to eq("crown")
    end

    it "returns 'shield-check' for admins" do
      create(:group_membership, :admin, group: group, user: user)
      expect(helper.group_role_icon(user, group)).to eq("shield-check")
    end

    it "returns 'users' for members" do
      create(:group_membership, group: group, user: user)
      expect(helper.group_role_icon(user, group)).to eq("users")
    end

    it "returns 'users' when no membership exists" do
      expect(helper.group_role_icon(user, group)).to eq("users")
    end
  end
end
