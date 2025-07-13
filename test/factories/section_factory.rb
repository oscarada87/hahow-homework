require "faker"

FactoryBot.define do
  factory :section do
    name { Faker::Lorem.word }
    sequence(:idx) { |n| n }
    association :course
  end
end
