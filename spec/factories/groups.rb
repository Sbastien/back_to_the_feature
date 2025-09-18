FactoryBot.define do
  factory :group do
    sequence(:name) { |n| "group_#{n}" }
    definition { 'username.starts_with? "test"' }
  end
end
