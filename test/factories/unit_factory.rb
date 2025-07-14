# == Schema Information
#
# Table name: units
#
#  id          :bigint           not null, primary key
#  content     :text             not null
#  description :text
#  idx         :integer          not null
#  name        :string           not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  section_id  :integer          not null
#
# Indexes
#
#  index_units_on_section_id  (section_id)
#
# Foreign Keys
#
#  fk_rails_...  (section_id => sections.id)
#
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
