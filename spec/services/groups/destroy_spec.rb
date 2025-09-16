require 'rails_helper'

RSpec.describe Groups::Destroy do
  let!(:group) { create(:group) }

  it 'destroys the group and returns success' do
    result = described_class.call(group: group)
    expect(result.success?).to eq(true)
    expect { group.reload }.to raise_error(ActiveRecord::RecordNotFound)
  end

  it 'returns failure when destroy fails' do
    allow(group).to receive(:destroy).and_return(false)
    allow(group).to receive_message_chain(:errors, :full_messages, :to_sentence).and_return('error')
    result = described_class.call(group: group)
    expect(result.success?).to eq(false)
    expect(result.error_message).to eq('error')
  end
end
