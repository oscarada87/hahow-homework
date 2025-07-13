require "faker"

FactoryBot.define do
  factory :course do
    name { Faker::Lorem.word }
    teacher_name { Faker::Name.name }
    description { Faker::Lorem.sentence }

    factory :with_sections_and_units do
      transient do
        sections_count { 3 }
        units_count { 4 }
      end

      after(:create) do |course, evaluator|
        evaluator.sections_count.times do |i|
          section = create(:section, course: course, idx: i)
          evaluator.units_count.times do |j|
            create(:unit, section: section, idx: j)
          end
        end
      end
    end
  end
end
