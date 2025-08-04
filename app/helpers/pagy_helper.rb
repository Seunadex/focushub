module PagyHelper
  include Pagy::Frontend

  def tailwind_pagy_nav(pagy, base_path: nil)
    previous_link = if pagy.prev
      link_to "&larr; Prev".html_safe, pagy_url_for(pagy, pagy.prev, base_path, url: true), class: "px-3 py-1 border text-gray-700 rounded hover:bg-gray-100 transition-colors duration-200"
    else
      content_tag(:span, "&larr; Prev".html_safe, class: "px-3 py-1 text-gray-400 border rounded")
    end

    next_link = if pagy.next
      link_to "Next &rarr;".html_safe, pagy_url_for(pagy, pagy.next, base_path, url: true), class: "px-3 py-1 border text-gray-700 rounded hover:bg-gray-100 transition-colors duration-200"
    else
      content_tag(:span, "Next &rarr;".html_safe, class: "px-3 py-1 text-gray-400 border rounded")
    end

    page_links = pagy.series.map do |item|
      case item
      when Integer
        link_to item, pagy_url_for(pagy, item, base_path, url: true), class: "px-3 py-1 border rounded text-gray-700 hover:bg-gray-100 transition-colors duration-200 #{'bg-gray-200 font-bold' if item == pagy.page}"
      when String
        content_tag(:span, item, class: "px-3 py-1 text-gray-400")
      end
    end.join.html_safe

    content_tag(:nav, class: "flex items-center space-x-2 mt-5") do
      safe_join([ previous_link, page_links, next_link ])
    end
  end

  private

  def pagy_url_for(pagy, page, base_path, url = false)
    p_vars = pagy.vars
    params = (request.GET || {}).dup
    params[p_vars[:page_param].to_s] = page

    base_path = base_path || infer_base_path
    "#{request.base_url if url}#{base_path}?#{Rack::Utils.build_nested_query(pagy_get_params(params))}#{p_vars[:anchor]}"
  end

  def pagy_get_params(params)
    params
  end

  def infer_base_path
    case request.path
    when %r{\A/tasks} then tasks_path
    when %r{\A/dashboard} then dashboard_path
    else request.path
    end
  end
end
