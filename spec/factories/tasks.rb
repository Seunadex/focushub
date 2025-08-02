FactoryBot.define do
  factory :task do
    title { Faker::Lorem.sentence }
    description { Faker::Lorem.paragraph }
    priority { %w[low medium high].sample }
    completed { false }
    completed_at { nil }
    user { association(:user) }
    due_date { Faker::Date.forward(days: 7) }
  end
end
