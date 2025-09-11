module GroupsHelper
  # Returns an icon name for a user's role in the group
  def group_role_icon(user, group)
    role = group.role_for(user)
    case role
    when "owner"
      "crown"
    when "admin"
      "shield-check"
    when "member"
      "users"
    end
  end
end
