class GroupPolicy
  attr_reader :user, :group

  def initialize(user, group)
    @user = user
    @group = group
  end

  def index?
    user.present?
  end

  def show?
    return false unless user && group
     group.member?(user)
  end

  def new?
    create?
  end

  def create?
    user.present?
  end

  def edit?
    update?
  end

  def update?
    return false unless user && group
    group.owned_by?(user) || group.role_for(user) == "admin"
  end

  def destroy?
    return false unless user && group
    group.owned_by?(user)
  end

  def rotate_join_token?
    return false unless user && group
    group.owned_by?(user) || group.role_for(user) == "admin"
  end
end
