FactoryBot.define do
  factory :group_invitation do
    association :group
    association :inviter, factory: :user
    invitee_email { Faker::Internet.unique.email }
    status { :pending }
    token { SecureRandom.urlsafe_base64(16) }
    expires_at { 7.days.from_now }

    trait :accepted do
      status { :accepted }
      accepted_at { Time.current }
    end

    trait :revoked do
      status { :revoked }
      revoked_at { Time.current }
    end
  end
end
