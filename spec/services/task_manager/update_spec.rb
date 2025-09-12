require 'rails_helper'

RSpec.describe TaskManager::Update do
  let(:task) { create(:task, title: 'Old', priority: 'low') }

  describe '#call' do
    it 'updates a task and returns success' do
      result = described_class.new(task: task, params: { title: 'New', priority: 'high' }).call
      expect(result).to be_success
      expect(task.reload.title).to eq('New')
      expect(task.priority).to eq('high')
    end

    it 'returns failure when update fails' do
      result = described_class.new(task: task, params: { title: '' }).call
      expect(result).to be_failure
      expect(result.error).to be_present
      expect(task.reload.title).to eq('Old')
    end
  end
end
