module PagyHelper
  include Pagy::Frontend

  def pagy_nav(pagy, page_param_name:, turbo_frame: nil, **options)
    css_classes = options[:class] || "flex items-center space-x-2 mt-5"

    previous_link = if pagy.prev
      link_to(
        "&larr; Prev".html_safe,
        build_url_with_param(page_param_name, pagy.prev),
        class: "px-2 py-1 border text-gray-700 rounded hover:bg-gray-100 transition-colors duration-200",
        data: turbo_frame ? { turbo_frame: turbo_frame } : {}
      )
    else
      content_tag(:span, "&larr; Prev".html_safe, class: "px-2 py-1 text-gray-400 border rounded")
    end

    next_link = if pagy.next
      link_to(
        "Next &rarr;".html_safe,
        build_url_with_param(page_param_name, pagy.next),
        class: "px-2 py-1 border text-gray-700 rounded hover:bg-gray-100 transition-colors duration-200",
        data: turbo_frame ? { turbo_frame: turbo_frame } : {}
      )
    else
      content_tag(:span, "Next &rarr;".html_safe, class: "px-2 py-1 text-gray-400 border rounded")
    end

    page_links = pagy.series.map do |item|
      case item
      when Integer
        current_page_class = item == pagy.page ? " bg-gray-200 font-bold" : ""
        link_to(
          item,
          build_url_with_param(page_param_name, item),
          class: "px-2 py-1 border rounded text-gray-700 hover:bg-gray-100 transition-colors duration-200#{current_page_class}",
          data: turbo_frame ? { turbo_frame: turbo_frame } : {}
        )
      when String
        content_tag(:span, item, class: "px-2 py-1 text-gray-400")
      end
    end.join.html_safe

    content_tag(:nav, class: css_classes) do
      safe_join([ previous_link, page_links, next_link ])
    end
  end

  private

  def build_url_with_param(param_name, page_number)
    # Get current params and update the specific page parameter
    current_params = request.query_parameters.dup
    current_params[param_name.to_s] = page_number.to_s

    # Build the URL manually
    base_path = request.path
    query_string = current_params.to_query

    "#{base_path}?#{query_string}"
  end
end
