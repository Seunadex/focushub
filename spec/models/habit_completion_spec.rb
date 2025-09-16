require 'rails_helper'

RSpec.describe HabitCompletion, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:habit).inverse_of(:habit_completions) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:habit) }
    it { is_expected.to validate_presence_of(:completed_on) }

    it "is invalid when completed_on is in the future" do
      habit = create(:habit)
      completion = build(:habit_completion, habit: habit, completed_on: Date.current + 1.day)
      expect(completion).to be_invalid
      expect(completion.errors[:completed_on]).to include("cannot be in the future")
    end
  end

  describe "callbacks" do
    let(:habit) { create(:habit) }

    it "updates the streak after creation" do
      expect(Habits::StreakCalculator).to receive_message_chain(:new, :calculate_and_save!)
      create(:habit_completion, habit: habit)
    end

    it "updates the progress after creation" do
      expect(Habits::ProgressCalculator).to receive_message_chain(:new, :calculate_and_save!)
      create(:habit_completion, habit: habit)
    end

    it "updates the streak after destruction" do
      completion = create(:habit_completion, habit: habit)
      expect(Habits::StreakCalculator).to receive_message_chain(:new, :calculate_and_save!)
      completion.destroy
    end

    it "updates the progress after destruction" do
      completion = create(:habit_completion, habit: habit)
      expect(Habits::ProgressCalculator).to receive_message_chain(:new, :calculate_and_save!)
      completion.destroy
    end
  end
end
