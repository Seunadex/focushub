require 'rails_helper'

RSpec.describe TaskManager::Complete do
  let(:task) { create(:task, completed: false, completed_at: nil) }

  describe '#call' do
    it 'marks task as completed and sets completed_at' do
      result = described_class.new(task: task, completed: true).call
      expect(result).to be_success
      t = result.value
      expect(t.completed).to eq(true)
      expect(t.completed_at).to be_present
    end

    it 'marks task as not completed and clears completed_at' do
      task.update!(completed: true, completed_at: Time.current)
      result = described_class.new(task: task, completed: false).call
      expect(result).to be_success
      t = result.value
      expect(t.completed).to eq(false)
      expect(t.completed_at).to be_nil
    end

    it 'returns failure when update fails' do
      allow(task).to receive(:update).and_return(false)
      result = described_class.new(task: task, completed: true).call
      expect(result).to be_failure
      expect(result.error).to eq('Error completing task.')
    end
  end
end
