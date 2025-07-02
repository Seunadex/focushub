module ApplicationHelper
  def time_based_greeting
    hour = Time.zone.now.hour

    case hour
    when 5..11
      "Good Morning"
    when 12..17
      "Good Afternoon"
    else
      "Good Evening"
    end
  end
end
