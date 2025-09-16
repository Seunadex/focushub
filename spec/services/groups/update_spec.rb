require 'rails_helper'

RSpec.describe Groups::Update do
  let(:group) { create(:group, name: 'Old Name') }

  it 'updates the group and returns success' do
    result = described_class.call(group: group, params: { name: 'New Name' })
    expect(result.success?).to eq(true)
    expect(group.reload.name).to eq('New Name')
  end

  it 'returns failure when update fails' do
    result = described_class.call(group: group, params: { name: '' })
    expect(result.success?).to eq(false)
    expect(result.error_message).to be_present
    expect(group.reload.name).to eq('Old Name')
  end
end
