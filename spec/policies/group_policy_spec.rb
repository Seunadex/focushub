require 'rails_helper'

RSpec.describe GroupPolicy do
  let(:group) { create(:group) }
  let(:user) { create(:user) }

  describe '#index?' do
    it 'allows when user is present' do
      policy = described_class.new(user, nil)
      expect(policy.index?).to be true
    end

    it 'denies when user is nil' do
      policy = described_class.new(nil, nil)
      expect(policy.index?).to be false
    end
  end

  describe '#show?' do
    it 'denies when user is nil' do
      policy = described_class.new(nil, group)
      expect(policy.show?).to be false
    end

    it 'denies when group is nil' do
      policy = described_class.new(user, nil)
      expect(policy.show?).to be false
    end

    it 'allows when user is an active member' do
      create(:group_membership, user: user, group: group, status: :active)
      policy = described_class.new(user, group)
      expect(policy.show?).to be true
    end

    it 'denies when user is not an active member' do
      create(:group_membership, user: user, group: group, status: :invited)
      policy = described_class.new(user, group)
      expect(policy.show?).to be false
    end
  end

  describe '#create?' do
    it 'allows when user is present' do
      policy = described_class.new(user, group)
      expect(policy.create?).to be true
    end

    it 'denies when user is nil' do
      policy = described_class.new(nil, group)
      expect(policy.create?).to be false
    end
  end

  describe '#new?' do
    it 'delegates to create?' do
      policy = described_class.new(user, group)
      expect(policy.new?).to eq(policy.create?)
    end
  end

  describe '#update?' do
    it 'allows owners' do
      create(:group_membership, :owner, user: user, group: group)
      policy = described_class.new(user, group)
      expect(policy.update?).to be true
    end

    it 'allows admins' do
      create(:group_membership, :admin, user: user, group: group)
      policy = described_class.new(user, group)
      expect(policy.update?).to be true
    end

    it 'denies regular members' do
      create(:group_membership, user: user, group: group)
      policy = described_class.new(user, group)
      expect(policy.update?).to be false
    end

    it 'denies non-members' do
      policy = described_class.new(user, group)
      expect(policy.update?).to be false
    end

    it 'denies when user is nil' do
      policy = described_class.new(nil, group)
      expect(policy.update?).to be false
    end
  end

  describe '#edit?' do
    it 'delegates to update?' do
      create(:group_membership, :admin, user: user, group: group)
      policy = described_class.new(user, group)
      expect(policy.edit?).to eq(policy.update?)
    end
  end

  describe '#destroy?' do
    it 'allows owners' do
      create(:group_membership, :owner, user: user, group: group)
      policy = described_class.new(user, group)
      expect(policy.destroy?).to be true
    end

    it 'denies admins' do
      create(:group_membership, :admin, user: user, group: group)
      policy = described_class.new(user, group)
      expect(policy.destroy?).to be false
    end

    it 'denies regular members' do
      create(:group_membership, user: user, group: group)
      policy = described_class.new(user, group)
      expect(policy.destroy?).to be false
    end

    it 'denies when user is nil' do
      policy = described_class.new(nil, group)
      expect(policy.destroy?).to be false
    end
  end

  describe '#rotate_join_token?' do
    it 'allows owners' do
      create(:group_membership, :owner, user: user, group: group)
      policy = described_class.new(user, group)
      expect(policy.rotate_join_token?).to be true
    end

    it 'allows admins' do
      create(:group_membership, :admin, user: user, group: group)
      policy = described_class.new(user, group)
      expect(policy.rotate_join_token?).to be true
    end

    it 'denies regular members' do
      create(:group_membership, user: user, group: group)
      policy = described_class.new(user, group)
      expect(policy.rotate_join_token?).to be false
    end

    it 'denies non-members' do
      policy = described_class.new(user, group)
      expect(policy.rotate_join_token?).to be false
    end

    it 'denies when user is nil' do
      policy = described_class.new(nil, group)
      expect(policy.rotate_join_token?).to be false
    end
  end
end
