class GroupInvitationPolicy
  attr_reader :user, :group

  def initialize(user, group)
    @user = user
    @group = group
  end

  def invite?
    return false unless user && group
    group.owned_by?(user) || group.role_for(user) == "admin"
  end
end
