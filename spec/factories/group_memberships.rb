FactoryBot.define do
  factory :group_membership do
    association :user
    association :group

    role { :member }
    status { :active }
    joined_at { Time.current }

    trait :admin do
      role { :admin }
    end

    trait :owner do
      role { :owner }
    end

    trait :invited do
      status { :invited }
    end

    trait :left do
      status { :left }
      left_at { Time.current }
    end
  end
end
