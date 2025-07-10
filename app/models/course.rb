# == Schema Information
#
# Table name: courses
#
#  id           :integer          not null, primary key
#  description  :text
#  name         :string
#  teacher_name :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
class Course < ApplicationRecord
  has_many :sections, dependent: :destroy
end
