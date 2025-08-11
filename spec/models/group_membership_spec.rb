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
end
