require 'rails_helper'

RSpec.describe GroupInvitation, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:group) }
    it { is_expected.to belong_to(:inviter).class_name("User") }
    it { is_expected.to belong_to(:invitee).class_name("User").optional }
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:status).with_values(%i[pending accepted revoked expired]) }
  end

  describe "validations" do
    let(:group)   { Group.create!(name: "Chess Club", privacy: :public_access) }
    let(:inviter) { create(:user) }
    let(:invitee) { create(:user, email: "invitee@example.com") }

    it "generates defaults on create (token, expires_at)" do
      invitation = described_class.create!(group: group, inviter: inviter, invitee_email: invitee.email)
      expect(invitation.token).to be_present
      expect(invitation.expires_at).to be_present
      expect(invitation.expires_at).to be > Time.current
    end

    it "validates presence of token" do
      invitation = described_class.new(group: group, inviter: inviter, invitee_email: invitee.email, token: nil)
      expect(invitation).to be_valid # token will be set by callback before validation
      invitation.save!
      expect(invitation.token).to be_present
    end

    it "validates uniqueness of token" do
      token = "fixed-token"
      described_class.create!(group: group, inviter: inviter, invitee_email: invitee.email, token: token, expires_at: 3.days.from_now)
      dup = described_class.new(group: group, inviter: inviter, invitee_email: invitee.email, token: token, expires_at: 4.days.from_now)
      expect(dup).not_to be_valid
      expect(dup.errors[:token]).to include("has already been taken")
    end

    it "requires a valid invitee_email format" do
      bad = described_class.new(group: group, inviter: inviter, invitee_email: "not-an-email")
      expect(bad).not_to be_valid
      expect(bad.errors[:invitee_email]).to include("is invalid")
    end

    it "requires invitee_email to exist as a user" do
      missing = described_class.new(group: group, inviter: inviter, invitee_email: "missing@example.com")
      expect(missing).not_to be_valid
      expect(missing.errors[:invitee_email]).to include("not found")
    end

    it "prevents inviting a user who is already a member" do
      # Make invitee an active member of the group
      GroupMembership.create!(group: group, user: invitee, role: :member, status: :active, joined_at: Time.current)

      record = described_class.new(group: group, inviter: inviter, invitee_email: invitee.email)
      expect(record).not_to be_valid
      expect(record.errors[:invitee_email]).to include("is already a member of this group.")
    end
  end

  describe "scopes" do
    let(:group)   { Group.create!(name: "Gamma", privacy: :public_access) }
    let(:inviter) { create(:user) }
    let(:invitee) { create(:user, email: "scoped@example.com") }

    it ".still_valid returns only pending, unexpired invitations" do
      valid = GroupInvitation.create!(group: group, inviter: inviter, invitee_email: invitee.email)
      expired = GroupInvitation.create!(group: group, inviter: inviter, invitee_email: invitee.email)
      expired.update_column(:expires_at, 1.day.ago)

      accepted = GroupInvitation.create!(group: group, inviter: inviter, invitee_email: invitee.email)
      accepted.update_column(:status, GroupInvitation.statuses[:accepted])

      # Simulate a record with no expiry
      no_expiry = GroupInvitation.create!(group: group, inviter: inviter, invitee_email: invitee.email)
      no_expiry.update_column(:expires_at, nil)

      results = GroupInvitation.still_valid.to_a
      expect(results).to include(valid)
      expect(results).to include(no_expiry)
      expect(results).not_to include(expired)
      expect(results).not_to include(accepted)
    end
  end

  describe "instance methods" do
    let(:group)   { Group.create!(name: "Delta", privacy: :public_access) }
    let(:inviter) { create(:user) }
    let(:invitee) { create(:user, email: "method@example.com") }

    describe "#expired?" do
      it "returns false when expires_at is nil" do
        inv = GroupInvitation.create!(group: group, inviter: inviter, invitee_email: invitee.email)
        inv.update_column(:expires_at, nil)
        expect(inv.expired?).to be(false)
      end

      it "returns false when expires_at is in the future" do
        inv = GroupInvitation.create!(group: group, inviter: inviter, invitee_email: invitee.email, expires_at: 2.days.from_now)
        expect(inv.expired?).to be(false)
      end

      it "returns true when expires_at is in the past" do
        inv = GroupInvitation.create!(group: group, inviter: inviter, invitee_email: invitee.email)
        inv.update_column(:expires_at, 1.day.ago)
        expect(inv.expired?).to be(true)
      end
    end

    describe "#mark_accepted!" do
      it "updates status and accepted_at for valid pending invitation" do
        inv = GroupInvitation.create!(group: group, inviter: inviter, invitee_email: invitee.email)
        expect { inv.mark_accepted! }.to change { inv.reload.status }.from("pending").to("accepted")
        expect(inv.accepted_at).to be_present
      end

      it "does nothing for expired invitations" do
        inv = GroupInvitation.create!(group: group, inviter: inviter, invitee_email: invitee.email)
        inv.update_column(:expires_at, 1.day.ago)
        expect { inv.mark_accepted! }.not_to change { inv.reload.status }
        expect(inv.accepted_at).to be_nil
      end

      it "does nothing for already accepted invitations" do
        inv = GroupInvitation.create!(group: group, inviter: inviter, invitee_email: invitee.email)
        inv.update!(status: :accepted, accepted_at: Time.current)
        expect { inv.mark_accepted! }.not_to change { inv.reload.accepted_at }
      end

      it "does nothing for revoked invitations" do
        inv = GroupInvitation.create!(group: group, inviter: inviter, invitee_email: invitee.email)
        inv.update!(status: :revoked)
        expect { inv.mark_accepted! }.not_to change { inv.reload.status }
        expect(inv.accepted_at).to be_nil
      end
    end
  end
end
