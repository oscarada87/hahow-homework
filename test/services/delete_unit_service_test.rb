# frozen_string_literal: true

require "test_helper"

class DeleteUnitServiceTest < ActiveSupport::TestCase
  def setup
    @course = FactoryBot.create(:with_sections_and_units, sections_count: 1, units_count: 2)
    @section = @course.sections.first
    @unit1 = @section.units.first
    @unit2 = @section.units.last
  end

  test "should delete unit if not last" do
    service = DeleteUnitService.new(@unit1.id)
    assert_difference("Unit.count", -1) do
      assert service.call
    end
    assert Unit.find_by(id: @unit1.id).nil?
  end

  test "should not delete last unit" do
    @unit2.destroy!
    service = DeleteUnitService.new(@unit1.id)
    assert_raises(DeleteUnitService::LastUnitError) do
      service.call
    end
    assert Unit.find_by(id: @unit1.id)
  end

  test "should raise not found if unit does not exist" do
    service = DeleteUnitService.new(-1)
    assert_raises(ActiveRecord::RecordNotFound) do
      service.call
    end
  end
end
