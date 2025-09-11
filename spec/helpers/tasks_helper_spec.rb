require 'rails_helper'

RSpec.describe TasksHelper, type: :helper do
  let(:user) { create(:user) }

  before do
    allow(helper).to receive(:current_user).and_return(user)
    allow(helper).to receive(:pagy_info).and_return('info')
    allow(helper).to receive(:pagy_nav).and_return('nav')
    allow(helper).to receive(:lucide_icon).and_return('')
  end

  describe '#dashboard_task_list' do
    it 'renders the empty state when no tasks are due today' do
      pagy_double = instance_double('Pagy', pages: 1)
      expected_relation = user.tasks.due_today.order(due_date: :asc)

      expect(helper).to receive(:pagy).with(expected_relation).and_return([ pagy_double, [] ])

      html = helper.dashboard_task_list
      dom = Capybara.string(html)

      expect(dom).to have_css('turbo-frame#dashboard_tasks')
      expect(html).to include('No tasks available for today.')
      expect(html).to include('info')
    end

    it 'renders task items for tasks due today' do
      due_today_task1 = create(:task, user: user, title: 'Task A', due_date: Date.current)
      due_today_task2 = create(:task, user: user, title: 'Task B', due_date: Date.current)
      _other_task     = create(:task, title: 'Not Today', due_date: Date.tomorrow) # different user by factory

      tasks_due_today = [ due_today_task1, due_today_task2 ]
      pagy_double = instance_double('Pagy', pages: 1)
      expected_relation = user.tasks.due_today.order(due_date: :asc)

      expect(helper).to receive(:pagy).with(expected_relation).and_return([ pagy_double, tasks_due_today ])

      html = helper.dashboard_task_list
      dom = Capybara.string(html)

      expect(dom).to have_css('turbo-frame#dashboard_tasks')
      expect(html).to include('Task A')
      expect(html).to include('Task B')
      expect(html).not_to include('No tasks available for today.')
      expect(html).to include('info')
    end
  end
end
