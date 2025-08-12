module GroupsHelper
  def is_owner?(group)
    group.group_memberships.exists?(user: current_user, role: "owner")
  end

  def is_member?(group)
    group.group_memberships.exists?(user: current_user, status: "active")
  end
end
