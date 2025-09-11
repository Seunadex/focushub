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

  describe "#period_completion_count" do
    include ActiveSupport::Testing::TimeHelpers

    let(:habit) { create(:habit) }

    around do |example|
      travel_to Date.new(2024, 5, 15) do
        example.run
      end
    end

    it "defaults to daily period" do
      create(:habit_completion, habit: habit, completed_on: Date.current)
      create(:habit_completion, habit: habit, completed_on: Date.current - 1.day)

      expect(habit.period_completion_count).to eq(1)
    end

    it "counts daily completions" do
      create(:habit_completion, habit: habit, completed_on: Date.current)
      create(:habit_completion, habit: habit, completed_on: Date.current)
      create(:habit_completion, habit: habit, completed_on: Date.current - 1.day)

      expect(habit.period_completion_count(:daily)).to eq(2)
    end

    it "counts weekly completions" do
      in_week = Date.current.beginning_of_week + 2.days
      out_week = Date.current.beginning_of_week - 1.day

      in_week = [ in_week, Date.current ].min
      create(:habit_completion, habit: habit, completed_on: in_week)
      create(:habit_completion, habit: habit, completed_on: out_week)

      expect(habit.period_completion_count(:weekly)).to eq(1)
    end

    it "counts bi-weekly completions (current two-week window)" do
      start_of_week = Date.current.beginning_of_week
      in_window = start_of_week + 3.days
      out_window = start_of_week - 2.days

      in_window = [ in_window, Date.current ].min
      create(:habit_completion, habit: habit, completed_on: in_window)
      create(:habit_completion, habit: habit, completed_on: out_window)

      expect(habit.period_completion_count(:bi_weekly)).to eq(1)
    end

    it "counts monthly completions" do
      in_month = Date.current.beginning_of_month + 10.days
      out_month = Date.current.prev_month.end_of_month

      create(:habit_completion, habit: habit, completed_on: in_month)
      create(:habit_completion, habit: habit, completed_on: out_month)

      expect(habit.period_completion_count(:monthly)).to eq(1)
    end

    it "counts quarterly completions" do
      in_quarter = Date.current.beginning_of_quarter + 5.days
      out_quarter = Date.current.prev_quarter.beginning_of_quarter + 10.days

      create(:habit_completion, habit: habit, completed_on: in_quarter)
      create(:habit_completion, habit: habit, completed_on: out_quarter)

      expect(habit.period_completion_count(:quarterly)).to eq(1)
    end

    it "counts annual completions" do
      in_year = Date.current.beginning_of_year + 20.days
      out_year = Date.current.prev_year.end_of_year

      create(:habit_completion, habit: habit, completed_on: in_year)
      create(:habit_completion, habit: habit, completed_on: out_year)

      expect(habit.period_completion_count(:annually)).to eq(1)
    end

    it "raises an error for invalid period" do
      expect { habit.period_completion_count(:invalid) }.to raise_error(ArgumentError)
    end
  end

  describe "#reset_streak!" do
    let(:habit) { create(:habit, streak: 7) }

    it "resets the streak to 0 and persists" do
      expect { habit.reset_streak! }.to change { habit.reload.streak }.from(7).to(0)
    end
  end
end
