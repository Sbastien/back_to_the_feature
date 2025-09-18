FactoryBot.define do
  factory :user do
    sequence(:username) { |n| "user#{n}" }
    password { "password" }
    role { "user" }

    trait :admin do
      role { "admin" }
    end
  end
end
