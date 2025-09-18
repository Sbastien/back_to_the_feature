FactoryBot.define do
  factory :flag do
    sequence(:name) { |n| "flag_#{n}" }
    description { "Test flag description" }
  end
end
