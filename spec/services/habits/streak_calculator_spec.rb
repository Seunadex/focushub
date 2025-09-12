require 'rails_helper'

RSpec.describe Habits::StreakCalculator do
  let(:habit) { create(:habit, frequency: :daily, target: 1, streak: 0) }

  it 'counts consecutive completed days including today' do
    create(:habit_completion, habit: habit, completed_on: Date.current)
    create(:habit_completion, habit: habit, completed_on: Date.current - 1.day)
    create(:habit_completion, habit: habit, completed_on: Date.current - 2.days)

    expect(described_class.new(habit).calculate).to eq(3)
  end

  it 'updates habit streak with calculate_and_save!' do
    create(:habit_completion, habit: habit, completed_on: Date.current)
    described_class.new(habit).calculate_and_save!
    expect(habit.reload.streak).to be >= 1
  end
end
