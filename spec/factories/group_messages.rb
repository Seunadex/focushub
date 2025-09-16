FactoryBot.define do
  factory :group_message do
    association :group
    association :user
    body { Faker::Lorem.sentence }
  end
end
