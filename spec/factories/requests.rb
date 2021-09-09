FactoryBot.define do
  factory :request do
    association :employee, factory: :user
    start_date { '2030-05-10' }
    end_date { '2030-05-25' }
  end
end
