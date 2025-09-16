require 'rails_helper'

RSpec.describe Group, type: :model do
  describe "Authorization" do
    it { is_expected.to have_many(:group_memberships) }
    it { is_expected.to have_many(:users).through(:group_memberships) }
  end

  describe "Validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:slug) }
    it { is_expected.to validate_uniqueness_of(:slug) }
    it { is_expected.to validate_presence_of(:privacy) }
  end

  describe "Instance methods" do
    let(:group) { Group.create!(name: "Team Alpha", privacy: :public_access) }
    let(:user)  { create(:user) }

    describe "#ensure_join_token!" do
      it "generates and persists a token when missing" do
        expect(group.join_token).to be_nil
        token = group.ensure_join_token!
        expect(token).to be_present
        expect(group.reload.join_token).to eq(token)
      end

      it "returns existing token without changing it" do
        first = group.ensure_join_token!
        second = group.ensure_join_token!
        expect(second).to eq(first)
        expect(group.reload.join_token).to eq(first)
      end
    end

    describe "#rotate_join_token!" do
      it "replaces the token with a new persisted value" do
        original = group.ensure_join_token!
        rotated = group.rotate_join_token!
        expect(rotated).to be_present
        expect(rotated).not_to eq(original)
        expect(group.reload.join_token).to eq(rotated)
      end
    end

    describe "#role_for" do
      it "returns the membership role when present" do
        create(:group_membership, group: group, user: user, role: :admin, status: :active, joined_at: Time.current)
        expect(group.role_for(user)).to eq("admin")
      end

      it "defaults to 'member' when no membership exists" do
        expect(group.role_for(user)).to eq("member")
      end
    end

    describe "#owned_by?" do
      it "is true for users with owner role" do
        create(:group_membership, group: group, user: user, role: :owner, status: :active, joined_at: Time.current)
        expect(group.owned_by?(user)).to be(true)
      end

      it "is false otherwise" do
        create(:group_membership, group: group, user: user)
        expect(group.owned_by?(user)).to be(false)
      end
    end

    describe "#member?" do
      it "is true for active members" do
        create(:group_membership, group: group, user: user, role: :member, status: :active, joined_at: Time.current)
        expect(group.member?(user)).to be(true)
      end

      it "is false for invited or left users" do
        create(:group_membership, group: group, user: user, role: :member, status: :invited, joined_at: Time.current)
        expect(group.member?(user)).to be(false)
      end
    end
  end
end
