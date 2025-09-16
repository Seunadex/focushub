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

  describe "#overdue?" do
    subject { build(:task, due_date: due_date) }

    context "when due_date is in the past" do
      let(:due_date) { 1.day.ago }
      it { is_expected.to be_overdue }
    end

    context "when due_date is in the future" do
      let(:due_date) { 1.day.from_now }
      it { is_expected.not_to be_overdue }
    end

    context "when due_date is today" do
      let(:due_date) { Date.current }
      it { is_expected.not_to be_overdue }
    end
  end
end
