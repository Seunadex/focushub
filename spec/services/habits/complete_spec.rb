require 'rails_helper'

RSpec.describe Habits::Complete do
  let(:habit) { create(:habit, frequency: :daily, target: 2, progress: 0) }

  it 'completes a habit for today and returns success' do
    result = described_class.new(habit: habit, completed: true).call
    expect(result).to be_success
    expect(result.value[:habit]).to eq(habit)
    expect(result.value[:completed]).to eq(true)
    expect(habit.habit_completions.where(completed_on: Date.current).count).to eq(1)
    expect(habit.reload.progress).to be >= 50
  end

  it 'undoes completion for today and returns success' do
    habit.complete!(Date.current)
    result = described_class.new(habit: habit, completed: false).call
    expect(result).to be_success
    expect(result.value[:completed]).to eq(false)
    expect(habit.habit_completions.where(completed_on: Date.current).count).to eq(0)
  end

  it 'returns failure when undoing without existing completion' do
    result = described_class.new(habit: habit, completed: false).call
    expect(result).to be_failure
    expect(result.error).to include('Failed to mark habit incomplete')
  end
end
