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
class Section < ApplicationRecord
  belongs_to :course
  has_many :units, dependent: :destroy
end
