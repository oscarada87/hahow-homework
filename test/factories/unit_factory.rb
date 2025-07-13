require "faker"

FactoryBot.define do
  factory :unit do
    name { Faker::Lorem.word }
    description { Faker::Lorem.sentence }
    content { Faker::Lorem.paragraph }
    sequence(:idx) { |n| n }
    association :section
  end
end
