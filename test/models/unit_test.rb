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
require "test_helper"

class UnitTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
