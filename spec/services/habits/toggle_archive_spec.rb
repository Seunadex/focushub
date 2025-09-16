require 'rails_helper'

RSpec.describe Habits::ToggleArchive do
  let(:habit) { create(:habit, active: true) }

  it 'archives an active habit and returns success' do
    result = described_class.new(habit: habit).call
    expect(result).to be_success
    expect(result.value[:was_active]).to eq(true)
    expect(result.value[:action]).to eq('archived')
    expect(habit.reload.active?).to eq(false)
  end

  it 'restores an archived habit and returns success' do
    habit.update!(active: false)
    result = described_class.new(habit: habit).call
    expect(result).to be_success
    expect(result.value[:was_active]).to eq(false)
    expect(result.value[:action]).to eq('restored')
    expect(habit.reload.active?).to eq(true)
  end

  it 'returns failure when archive/restore raises' do
    allow(habit).to receive(:archive!).and_raise(StandardError.new('boom'))
    result = described_class.new(habit: habit).call
    expect(result).to be_failure
    expect(result.error).to eq('boom')
  end
end
