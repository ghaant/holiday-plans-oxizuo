FactoryBot.define do
  factory :user do
    sequence(:name) { |n| "Some Name#{n}" }
  end
end
