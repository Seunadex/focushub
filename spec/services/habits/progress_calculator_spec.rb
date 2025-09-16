require 'rails_helper'

RSpec.describe Habits::ProgressCalculator do
  let(:habit) { create(:habit, frequency: :daily, target: 4, progress: 0) }

  it 'calculates progress based on completions and saves it' do
    # 3 completions today against target 4 => 75%
    3.times { create(:habit_completion, habit: habit, completed_on: Date.current) }

    progress = described_class.new(habit).calculate_and_save!
    expect(progress).to eq(75)
    expect(habit.reload.progress).to eq(75)
  end

  it 'caps progress at 100' do
    10.times { create(:habit_completion, habit: habit, completed_on: Date.current) }
    progress = described_class.new(habit).calculate_and_save!
    expect(progress).to eq(100)
  end
end
