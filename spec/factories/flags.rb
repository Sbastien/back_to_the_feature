FactoryBot.define do
  factory :flag do
    sequence(:name) { |n| "flag_#{n}" }
    description { "Test flag description" }
    variants do
      [
        { "name" => "A", "weight" => 50 },
        { "name" => "B", "weight" => 50 }
      ]
    end
  end
end