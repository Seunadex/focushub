require 'rails_helper'

RSpec.describe GroupInvitationPolicy do
  let(:group) { create(:group) }
  let(:user) { create(:user) }

  describe '#invite?' do
    it 'allows owners' do
      create(:group_membership, :owner, user: user, group: group)
      policy = described_class.new(user, group)
      expect(policy.invite?).to be true
    end

    it 'allows admins' do
      create(:group_membership, :admin, user: user, group: group)
      policy = described_class.new(user, group)
      expect(policy.invite?).to be true
    end

    it 'denies regular members' do
      create(:group_membership, user: user, group: group)
      policy = described_class.new(user, group)
      expect(policy.invite?).to be false
    end

    it 'denies non-members' do
      policy = described_class.new(user, group)
      expect(policy.invite?).to be false
    end

    it 'denies when user is nil' do
      policy = described_class.new(nil, group)
      expect(policy.invite?).to be false
    end
  end
end
