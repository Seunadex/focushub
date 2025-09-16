require 'rails_helper'

RSpec.describe GroupMembership, type: :model do
  describe "Associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:group) }
  end

  describe "Validations" do
    it { is_expected.to validate_presence_of(:role) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:user) }
    it { is_expected.to validate_presence_of(:group) }
    it { is_expected.to validate_presence_of(:joined_at).on(:create) }
    it { is_expected.to validate_presence_of(:last_read_at).on(:update) }
  end

  describe "Methods" do
    let(:group) { Group.create!(name: "Team Alpha", privacy: :public_access) }
    let(:user)  { create(:user) }

    describe "enum predicates" do
      it "returns true for matching role and status" do
        gm = build(:group_membership, group: group, user: user, role: :admin, status: :active)
        expect(gm.admin?).to be(true)
        expect(gm.active?).to be(true)
        expect(gm.owner?).to be(false)
        expect(gm.invited?).to be(false)
      end

      it "handles other roles and statuses" do
        gm = build(:group_membership, group: group, user: user, role: :owner, status: :left)
        expect(gm.owner?).to be(true)
        expect(gm.left?).to be(true)
        expect(gm.member?).to be(false)
        expect(gm.active?).to be(false)
      end
    end

    describe "status-change callbacks" do
      it "recounts members_count when becoming active" do
        gm = create(
          :group_membership,
          group: group,
          user: user,
          role: :member,
          status: :invited,
          last_read_at: Time.current
        )

        gm.update!(status: :active)
        expect(group.reload.members_count).to eq(group.group_memberships.where(status: :active).count)
      end

      it "recounts members_count when becoming inactive" do
        gm = create(
          :group_membership,
          group: group,
          user: user,
          role: :member,
          status: :active,
          last_read_at: Time.current
        )

        gm.update!(status: :left)
        # TODO: check this again later
        expect(group.members_count).to eq(group.group_memberships.where(status: :active).count)
      end

      it "decrements members_count when destroyed if became inactive" do
        gm = create(
          :group_membership,
          group: group,
          user: user,
          role: :member,
          status: :active,
          last_read_at: Time.current
        )
        expect(group.members_count).to eq(1)

        gm.destroy
        expect(group.members_count).to eq(0)
      end
    end
  end
end
