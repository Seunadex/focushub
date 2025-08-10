class BestStreaksQuery
  def self.for_user(user)
    scope = user.habits.active.where("streak > 0")
    [
      BestStreakPresenter.new(:daily,     scope.where(frequency: :daily).order(streak: :desc).first),
      BestStreakPresenter.new(:weekly,    scope.where(frequency: :weekly).order(streak: :desc).first),
      BestStreakPresenter.new(:bi_weekly, scope.where(frequency: :bi_weekly).order(streak: :desc).first),
      BestStreakPresenter.new(:monthly,   scope.where(frequency: :monthly).order(streak: :desc).first),
      BestStreakPresenter.new(:quarterly, scope.where(frequency: :quarterly).order(streak: :desc).first),
      BestStreakPresenter.new(:annually,  scope.where(frequency: :annually).order(streak: :desc).first)
    ]
  end
end
