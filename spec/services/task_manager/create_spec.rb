require 'rails_helper'

RSpec.describe TaskManager::Create do
  let(:user) { create(:user) }

  describe '#call' do
    it 'creates a task and returns success' do
      params = {
        title: 'Test task',
        description: 'Do something',
        priority: 'medium',
        due_date: Date.current
      }

      result = described_class.new(user: user, params: params).call

      expect(result).to be_success
      task = result.value
      expect(task).to be_persisted
      expect(task.user).to eq(user)
      expect(task.title).to eq('Test task')
    end

    it 'returns failure on validation error' do
      params = { title: '', priority: 'low', due_date: Date.current }
      result = described_class.new(user: user, params: params).call

      expect(result).to be_failure
      expect(result.error).to be_present
    end
  end
end
