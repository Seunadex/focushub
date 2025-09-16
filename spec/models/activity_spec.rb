require 'rails_helper'

RSpec.describe Activity, type: :model do
  describe "Associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:group) }
    it { is_expected.to belong_to(:subject) }
  end

  describe "Validations" do
    it { is_expected.to validate_presence_of(:kind) }
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_presence_of(:group_id) }
    it { is_expected.to validate_presence_of(:subject_type) }
    it { is_expected.to validate_presence_of(:subject_id) }
  end

  describe "Enums" do
    it { is_expected.to define_enum_for(:kind).with_values(created: 0, updated: 1, deleted: 2) }
  end
end
