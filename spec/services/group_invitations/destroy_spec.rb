require 'rails_helper'

RSpec.describe GroupInvitations::Destroy do
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let!(:invitation) { create(:group_invitation, group: group, invitee_email: user.email) }

  it 'revokes the invitation and returns success' do
    result = described_class.call(group: group, id: invitation.id)
    expect(result.success?).to eq(true)
    expect(invitation.reload.revoked?).to eq(true)
    expect(invitation.revoked_at).to be_present
  end

  it 'returns success if already revoked' do
    invitation.update!(status: :revoked, revoked_at: Time.current)
    result = described_class.call(group: group, id: invitation.id)
    expect(result.success?).to eq(true)
  end

  it 'returns not found when invitation is missing' do
    result = described_class.call(group: group, id: -1)
    expect(result.success?).to eq(false)
    expect(result.error_message).to eq('Invitation not found.')
  end

  it 'returns failure when update fails' do
    allow_any_instance_of(GroupInvitation).to receive(:update).and_return(false)
    allow_any_instance_of(GroupInvitation).to receive_message_chain(:errors, :full_messages, :to_sentence).and_return('update failed')
    result = described_class.call(group: group, id: invitation.id)
    expect(result.success?).to eq(false)
    expect(result.error_message).to eq('update failed')
  end
end
