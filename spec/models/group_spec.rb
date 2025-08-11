require 'rails_helper'

RSpec.describe Group, type: :model do
  describe "Authorization" do
    it { is_expected.to have_many(:group_memberships) }
    it { is_expected.to have_many(:users).through(:group_memberships) }
  end

  describe "Validations" do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:slug) }
    it { is_expected.to validate_uniqueness_of(:slug) }
    it { is_expected.to validate_presence_of(:privacy) }
  end
end
