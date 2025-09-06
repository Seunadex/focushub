module GroupsHelper
  def group_role_icon(user, group)
    role = group.role_for(user)
    case role
    when "owner"
      "crown"
    when "admin"
      "shield-check"
    when "member"
      "users"
    else
      "users"
    end
  end
end
