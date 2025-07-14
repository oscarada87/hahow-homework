# frozen_string_literal: true

require "test_helper"

class DeleteSectionServiceTest < ActiveSupport::TestCase
  def setup
    @course = FactoryBot.create(:with_sections_and_units, sections_count: 2, units_count: 2)
    @section1 = @course.sections.first
    @section2 = @course.sections.last
  end

  test "should delete section if not last" do
    units = @section1.units.pluck(:id)
    service = DeleteSectionService.new(@section1.id)
    assert_difference("Section.count", -1) do
      assert service.call
    end
    assert Section.find_by(id: @section1.id).nil?
    units.each do |unit_id|
      assert Unit.find_by(id: unit_id).nil?, "Unit ##{unit_id} should be deleted when section is deleted"
    end
  end

  test "should not delete last section" do
    @section2.destroy!
    service = DeleteSectionService.new(@section1.id)
    assert_raises(DeleteSectionService::LastSectionError) do
      service.call
    end
    assert Section.find_by(id: @section1.id)
  end

  test "should raise not found if section does not exist" do
    service = DeleteSectionService.new(-1)
    assert_raises(ActiveRecord::RecordNotFound) do
      service.call
    end
  end
end
