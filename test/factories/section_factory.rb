# == Schema Information
#
# Table name: sections
#
#  id         :bigint           not null, primary key
#  idx        :integer          not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  course_id  :integer          not null
#
# Indexes
#
#  index_sections_on_course_id  (course_id)
#
# Foreign Keys
#
#  fk_rails_...  (course_id => courses.id)
#
require "faker"

FactoryBot.define do
  factory :section do
    name { Faker::Lorem.word }
    sequence(:idx) { |n| n }
    association :course
  end
end
