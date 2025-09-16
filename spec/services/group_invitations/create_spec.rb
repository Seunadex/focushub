require 'rails_helper'

RSpec.describe GroupInvitations::Create do
  let(:group) { create(:group) }
  let(:inviter) { create(:user) }
  let(:invitee) { create(:user) }

  it 'creates an invitation and returns success' do
    result = described_class.call(group: group, inviter: inviter, invitee_email: invitee.email)
    expect(result.success?).to eq(true)
    invitation = result.invitation
    expect(invitation).to be_persisted
    expect(invitation.group).to eq(group)
    expect(invitation.inviter).to eq(inviter)
    expect(invitation.invitee_email).to eq(invitee.email.downcase)
  end

  it 'fails when a pending invitation exists for the same email' do
    create(:group_invitation, group: group, inviter: inviter, invitee_email: invitee.email)
    result = described_class.call(group: group, inviter: inviter, invitee_email: invitee.email)
    expect(result.success?).to eq(false)
    expect(result.error_message).to include('pending invitation')
  end

  it 'fails when email is invalid' do
    result = described_class.call(group: group, inviter: inviter, invitee_email: '')
    expect(result.success?).to eq(false)
    expect(result.error_message).to be_present
  end
end
