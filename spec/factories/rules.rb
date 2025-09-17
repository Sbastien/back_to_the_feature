FactoryBot.define do
  factory :rule do
    flag
    type { "boolean" }
    value { "on" }

    trait :boolean_on do
      type { "boolean" }
      value { "on" }
    end

    trait :boolean_off do
      type { "boolean" }
      value { "off" }
    end

    trait :percentage do
      type { "percentage_of_actors" }
      value { "50" }
    end

    trait :group_rule do
      type { "group" }
      value { "test_group" }
    end
  end
end