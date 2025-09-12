require 'rails_helper'

RSpec.describe TaskManager::Destroy do
  let!(:task) { create(:task) }

  describe '#call' do
    it 'destroys the task and returns success' do
      result = described_class.new(task: task).call
      expect(result).to be_success
      expect { task.reload }.to raise_error(ActiveRecord::RecordNotFound)
    end

    it 'returns failure when destroy fails' do
      allow(task).to receive(:destroy).and_return(false)
      result = described_class.new(task: task).call
      expect(result).to be_failure
      expect(result.error).to eq('Unable to delete task.')
    end
  end
end
