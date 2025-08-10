class BestStreakPresenter
  attr_reader :frequency, :habit

  def initialize(frequency, habit)
    @frequency = frequency
    @habit = habit
  end

  def frequency_label
    frequency.to_s.humanize
  end

  def streak
    habit&.streak || 0
  end

  def title
    habit&.title
  end
end
