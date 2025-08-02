FactoryBot.define do
  factory :habit do
    title { Faker::Lorem.sentence }
    frequency { %w[daily weekly bi_weekly monthly quarterly annually].sample }
    description { Faker::Lorem.paragraph }
    target { rand(1..10) }
    streak { rand(0..30) }
    active { true }
    user { association(:user) }
    progress { 0 }

    trait :inactive do
      active { false }
    end

    trait :low_priority do
      priority { "low" }
    end

    trait :medium_priority do
      priority { "medium" }
    end

    trait :high_priority do
      priority { "high" }
    end
  end
end
