require 'rails_helper'

RSpec.describe PagyHelper, type: :helper do
  describe '#pagy_nav' do
    let(:request_double) do
      instance_double(ActionDispatch::Request,
        path: '/dashboard',
        query_parameters: { 'filters' => 'open' })
    end

    before do
      allow(helper).to receive(:request).and_return(request_double)
    end

    it 'renders nav with prev/next links, page links and turbo-frame data' do
      pagy = instance_double('Pagy', prev: 1, next: 3, page: 2, series: [ 1, 2, 3 ])

      html = helper.pagy_nav(pagy, page_param_name: :tasks_page, turbo_frame: 'dashboard_tasks')
      dom = Capybara.string(html)

      # Outer container
      expect(dom).to have_css('nav.flex.items-center.space-x-2.mt-5')

      # Prev/Next links
      expect(dom).to have_link('← Prev')
      expect(dom).to have_link('Next →')

      # Page links and current page highlighting
      expect(dom).to have_link('1')
      expect(dom).to have_link('3')
      expect(dom).to have_css('a.bg-gray-200.font-bold', text: '2')

      # URLs include existing params and the correct page param
      expect(html).to include('/dashboard?')
      expect(html).to include('filters=open')
      expect(html).to include('tasks_page=1')
      expect(html).to include('tasks_page=2')
      expect(html).to include('tasks_page=3')

      # Turbo Frame data attribute on links
      expect(html).to include('data-turbo-frame="dashboard_tasks"')
    end

    it 'disables prev/next when missing and renders string series items' do
      pagy = instance_double('Pagy', prev: nil, next: nil, page: 1, series: [ 1, '...', 10 ])

      html = helper.pagy_nav(pagy, page_param_name: :habits_page)
      dom = Capybara.string(html)

      # Disabled prev/next should be spans, not links
      expect(dom).to have_css('span', text: '← Prev')
      expect(dom).to have_css('span', text: 'Next →')

      # Renders string items (e.g., ellipsis) as spans
      expect(dom).to have_css('span', text: '...')
    end
  end
end
