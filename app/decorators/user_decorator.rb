class UserDecorator < Draper::Decorator
  delegate_all

  def full_name
    "#{object.first_name} #{object.last_name}".presence
  end

  def abbreviated_name
    return "#{object.first_name.first}#{object.last_name.first}".upcase if object.first_name.present? && object.last_name.present?
    return object.first_name.first.upcase if object.first_name.present?
    return object.last_name.first.upcase if object.last_name.present?
    nil
  end
end
