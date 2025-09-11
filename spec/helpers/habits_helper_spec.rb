require 'rails_helper'

RSpec.describe HabitsHelper, type: :helper do
  describe '#habit_streak_text' do
    it 'returns message when streak is zero' do
      habit = double('Habit', streak: 0, frequency: 'daily')
      expect(helper.habit_streak_text(habit)).to eq('No streak data available')
    end

    it 'returns message when streak is nil' do
      habit = double('Habit', streak: nil, frequency: 'weekly')
      expect(helper.habit_streak_text(habit)).to eq('No streak data available')
    end

    it 'formats daily streaks' do
      habit = double('Habit', streak: 3, frequency: 'daily')
      expect(helper.habit_streak_text(habit)).to eq('3 consecutive days')
    end

    it 'formats weekly streaks' do
      habit = double('Habit', streak: 5, frequency: 'weekly')
      expect(helper.habit_streak_text(habit)).to eq('5 consecutive weeks')
    end

    it 'formats monthly streaks' do
      habit = double('Habit', streak: 2, frequency: 'monthly')
      expect(helper.habit_streak_text(habit)).to eq('2 consecutive months')
    end

    it 'formats quarterly streaks' do
      habit = double('Habit', streak: 4, frequency: 'quarterly')
      expect(helper.habit_streak_text(habit)).to eq('4 consecutive quarters')
    end

    it 'formats annual streaks' do
      habit = double('Habit', streak: 1, frequency: 'annually')
      expect(helper.habit_streak_text(habit)).to eq('1 consecutive years')
    end

    it 'formats bi-weekly streaks' do
      habit = double('Habit', streak: 3, frequency: 'bi_weekly')
      expect(helper.habit_streak_text(habit)).to eq('3 consecutive bi-weeks')
    end

    it 'returns no data for no frequency' do
      habit = double('Habit', streak: 3, frequency: nil)
      expect(helper.habit_streak_text(habit)).to eq('No streak data available')
    end
  end

  describe '#active_habit_list' do
    let(:user) { create(:user) }

    before do
      allow(helper).to receive(:current_user).and_return(user)
      allow(helper).to receive(:pagy_info).and_return('info')
      allow(helper).to receive(:pagy_nav).and_return('nav')
      allow(helper).to receive(:lucide_icon).and_return('')
    end

    it 'renders the empty state when no active habits' do
      pagy_double = instance_double('Pagy', pages: 1)
      expected_relation = user.habits.active.order(created_at: :desc)

      expect(helper).to receive(:pagy).with(expected_relation).and_return([ pagy_double, [] ])

      html = helper.active_habit_list
      dom = Capybara.string(html)

      expect(dom).to have_css('turbo-frame#habits')
      expect(html).to include('No active habits found.')
      expect(html).to include('info')
    end

    it 'renders items for active habits' do
      habit_a = create(:habit, user: user, title: 'Hydrate')
      habit_b = create(:habit, user: user, title: 'Read')
      _inactive = create(:habit, :inactive, user: user, title: 'Archived Habit')
      _other_user_habit = create(:habit, title: 'Not Mine')

      pagy_double = instance_double('Pagy', pages: 1)
      expected_relation = user.habits.active.order(created_at: :desc)

      expect(helper).to receive(:pagy).with(expected_relation).and_return([ pagy_double, [ habit_a, habit_b ] ])

      html = helper.active_habit_list
      dom = Capybara.string(html)

      expect(dom).to have_css('turbo-frame#habits')
      expect(html).to include('Hydrate')
      expect(html).to include('Read')
      expect(html).not_to include('No active habits found.')
      expect(html).to include('info')
    end
  end
end
