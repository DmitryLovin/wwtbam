FactoryBot.define do
  factory :user do
    name { "John_#{rand(999)}" }

    sequence(:email) { |n| "example_#{n}@mail.me" }

    is_admin { false }
    balance { 0 }

    after(:build) { |u| u.password_confirmation = u.password = "123456" }
  end
end
