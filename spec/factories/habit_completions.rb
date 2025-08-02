FactoryBot.define do
  factory :habit_completion do
    habit { association(:habit) }
    completed_on { Date.current }
  end
end
