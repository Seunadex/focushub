require "rails_helper"

RSpec.describe GroupInvitationMailer, type: :mailer do
  describe "#invite" do
    let(:inviter) { create(:user, first_name: "Frank") }
    let(:invitee) { create(:user, email: "seun@example.com") }
    let(:group)   { Group.create!(name: "Chess Club", privacy: :private_access) }
    let(:invitation) do
      GroupInvitation.create!(group: group, inviter: inviter, invitee_email: invitee.email)
    end

    subject(:mail) { described_class.with(invitation: invitation).invite }

    it "sets the correct headers and content" do
      expect(mail.to).to eq([ invitee.email ])
      expect(mail.from).to eq([ "from@example.com" ])
      expect(mail.subject).to eq("Frank has invited you to join the group Chess Club")


      expect(mail.body.encoded).to include(group.name)
      expect(mail.body.encoded).to include("http://example.com/invites/#{invitation.token}")
      expect(mail.body.encoded).to include("Accept invitation")
    end
  end
end
