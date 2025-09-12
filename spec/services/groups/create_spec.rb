require 'rails_helper'

RSpec.describe Groups::Create do
  let(:creator) { create(:user) }

  it 'creates a group and owner membership' do
    params = { name: 'My Group', description: 'desc', privacy: :public_access }
    result = described_class.call(params: params, creator: creator)

    expect(result.success?).to eq(true)
    group = result.group
    expect(group).to be_persisted
    membership = group.group_memberships.find_by(user: creator)
    expect(membership).to be_present
    expect(membership.role).to eq('owner')
    expect(membership.status).to eq('active')
  end

  it 'returns failure when validation fails' do
    params = { name: '', description: 'desc', privacy: :public_access }
    result = described_class.call(params: params, creator: creator)
    expect(result.success?).to eq(false)
    expect(result.error_message).to be_present
    expect(result.group).to be_present
    expect(result.group).not_to be_persisted
  end

  it 'rescues exceptions and returns failure' do
    allow(Group).to receive(:transaction).and_raise(StandardError.new('boom'))
    params = { name: 'X', description: 'Y', privacy: :public_access }
    result = described_class.call(params: params, creator: creator)
    expect(result.success?).to eq(false)
    expect(result.error_message).to eq('boom')
  end
end
