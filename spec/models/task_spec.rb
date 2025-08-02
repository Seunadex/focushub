require 'rails_helper'

RSpec.describe Task, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
  end

  describe "validations" do
    subject { build(:task, priority: "medium") }
    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_length_of(:title).is_at_most(100) }
    it { is_expected.to validate_presence_of(:due_date) }
    it { is_expected.to validate_presence_of(:priority) }
    it { is_expected.to allow_value("low").for(:priority) }
    it { is_expected.to allow_value("medium").for(:priority) }
    it { is_expected.to allow_value("high").for(:priority) }
  end
end
