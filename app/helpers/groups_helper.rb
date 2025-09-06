module GroupsHelper
  def is_owner?(group)
    group.group_memberships.exists?(user: current_user, role: "owner")
  end

  def is_member?(group)
    group.group_memberships.exists?(user: current_user, status: "active")
  end

  def group_role_icon(user, group)
    role = group.role_for(user)
    case role
    when "owner"
      "crown"
    when "admin"
      "shield-check"
    when "member"
      "user"
    else
      "user"
    end
  end
end
