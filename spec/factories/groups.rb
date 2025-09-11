FactoryBot.define do
  factory :group do
    name { Faker::Team.unique.name }
    description { Faker::Lorem.sentence }
    privacy { :public_access }
  end
end
