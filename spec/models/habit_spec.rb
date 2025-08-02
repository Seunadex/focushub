require 'rails_helper'

RSpec.describe Habit, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to have_many(:habit_completions).inverse_of(:habit).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:habit) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:target) }
    it { is_expected.to validate_numericality_of(:target).only_integer.is_greater_than(0) }
    it { is_expected.to validate_presence_of(:frequency) }
    it { is_expected.to define_enum_for(:frequency).with_values(daily: 0, weekly: 1, bi_weekly: 2, monthly: 3, quarterly: 4, annually: 5) }
  end

  describe "scopes" do
    let!(:active_habit) { create(:habit, active: true) }
    let!(:archived_habit) { create(:habit, active: false) }

    it "returns active habits" do
      expect(Habit.active).to include(active_habit)
      expect(Habit.active).not_to include(archived_habit)
    end

    it "returns archived habits" do
      expect(Habit.archived).to include(archived_habit)
      expect(Habit.archived).not_to include(active_habit)
    end
  end

  describe "#complete!" do
    let(:habit) { create(:habit) }

    it "creates a habit completion for the current date" do
      expect { habit.complete! }.to change { habit.habit_completions.count }.by(1)
      expect(habit.habit_completions.last.completed_on).to eq(Date.current)
    end
  end

  describe "#undo_complete!" do
    let(:habit) { create(:habit) }

    before do
      habit.complete!
    end

    it "removes the habit completion for the current date" do
      expect { habit.undo_complete! }.to change { habit.habit_completions.count }.by(-1)
      expect(habit.habit_completions.find_by(completed_on: Date.current)).to be_nil
    end

    it "returns false if no completion exists for the given date" do
      expect(habit.undo_complete!(Date.yesterday)).to be_falsey
    end
  end

  describe "#archive!" do
    let(:habit) { create(:habit, active: true) }

    it "sets the habit to inactive" do
      expect { habit.archive! }.to change(habit, :active).from(true).to(false)
    end
  end

  describe "#restore!" do
    let(:habit) { create(:habit, active: false) }

    it "sets the habit to active" do
      expect { habit.restore! }.to change(habit, :active).from(false).to(true)
    end
  end
end
