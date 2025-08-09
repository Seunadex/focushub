require 'rails_helper'

RSpec.describe UpdateStreakAndProgressJob, type: :job do
  include ActiveJob::TestHelper

  describe '#perform' do
    let!(:habit1) { create(:habit) }
    let!(:habit2) { create(:habit) }
    let!(:habit3) { create(:habit) }

    before do
      allow(Habit).to receive_message_chain(:active).and_return(Habit.where(id: [ habit1.id, habit2.id ]))
    end

    it 'enqueues on the default queue' do
      expect {
        described_class.perform_later
      }.to have_enqueued_job(described_class).on_queue('default')
    end

    it 'processes all active habits (id-only batching) and invokes calculators once per habit' do
      progress_calls = []
      streak_calls   = []

      allow(Habits::ProgressCalculator).to receive(:new) do |habit|
        progress_calls << habit.id
        instance_double('Habits::ProgressCalculator', calculate_and_save!: true)
      end

      allow(Habits::StreakCalculator).to receive(:new) do |habit|
        streak_calls << habit.id
        instance_double('Habits::StreakCalculator', calculate_and_save!: true)
      end

      perform_enqueued_jobs { described_class.perform_later }

      expect(progress_calls).to match_array([ habit1.id, habit2.id ])
      expect(streak_calls).to   match_array([ habit1.id, habit2.id ])
    end

    it 'scopes to a single habit when habit_id is provided' do
      progress_ids = []
      streak_ids   = []

      allow(Habits::ProgressCalculator).to receive(:new) { |habit| progress_ids << habit.id; instance_double('PCalc', calculate_and_save!: true) }
      allow(Habits::StreakCalculator).to receive(:new) { |habit| streak_ids << habit.id;   instance_double('SCalc', calculate_and_save!: true) }

      described_class.perform_now(habit_id: habit2.id)

      expect(progress_ids).to eq([ habit2.id ])
      expect(streak_ids).to   eq([ habit2.id ])
    end

    it 'continues processing other habits when one raises (resilient to per-record failure)' do
      bad_id = habit1.id
      processed = []

      allow(Habits::ProgressCalculator).to receive(:new) do |habit|
        instance_double('PCalc').tap do |d|
          allow(d).to receive(:calculate_and_save!) do
            processed << habit.id
            raise StandardError, 'boom' if habit.id == bad_id
            true
          end
        end
      end

      allow(Habits::StreakCalculator).to receive(:new) do |habit|
        instance_double('SCalc', calculate_and_save!: true)
      end

      expect {
        described_class.perform_now
      }.not_to raise_error

      # habit1 fails on progress; habit2 still processed
      expect(processed).to include(habit1.id, habit2.id)
    end

    it 'no-ops safely when passed a non-existent habit_id' do
      allow(Habits::ProgressCalculator).to receive(:new)
      allow(Habits::StreakCalculator).to receive(:new)

      expect {
        described_class.perform_now(habit_id: 999_999)
      }.not_to raise_error

      expect(Habits::ProgressCalculator).not_to have_received(:new)
      expect(Habits::StreakCalculator).not_to have_received(:new)
    end
  end
end
