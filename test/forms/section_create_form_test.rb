# frozen_string_literal: true

require "test_helper"

class SectionCreateFormTest < ActiveSupport::TestCase
  def setup
    @course = FactoryBot.create(:with_sections_and_units, sections_count: 1, units_count: 2)
  end

  test "valid params should create section and units" do
    params = {
      course_id: @course.id,
      name: "章節二",
      idx: 1,
      units: [
        { name: "單元一", description: "說明A", content: "內容A", idx: 0 },
        { name: "單元二", description: "說明B", content: "內容B", idx: 1 }
      ]
    }
    form = SectionCreateForm.new(params)
    section = form.save
    assert section.persisted?
    assert_equal "章節二", section.name
    assert_equal 2, section.units.count
    assert_equal "單元一", section.units.first.name
  end

  test "missing name should not create section" do
    params = {
      course_id: @course.id,
      name: "",
      idx: 1,
      units: [ { name: "單元一", description: "說明A", content: "內容A", idx: 0 } ]
    }
    form = SectionCreateForm.new(params)
    refute form.save
    assert_includes form.errors.full_messages.join, "Name can't be blank"
  end

  test "missing course should not create section" do
    params = {
      course_id: nil,
      name: "章節二",
      idx: 1,
      units: [ { name: "單元一", description: "說明A", content: "內容A", idx: 0 } ]
    }
    form = SectionCreateForm.new(params)
    refute form.save
    assert_includes form.errors.full_messages.join, "Course can't be blank"
  end

  test "units can't be empty" do
    params = {
      course_id: @course.id,
      name: "章節二",
      idx: 1,
      units: []
    }
    form = SectionCreateForm.new(params)
    refute form.save
    assert_includes form.errors.full_messages.join, "must not be empty"
  end

  test "should raise error if section not found" do
    params = {
      course_id: -999,
      name: "章節二",
      idx: 1,
      units: [ { name: "單元一", description: "說明A", content: "內容A", idx: 0 } ]
    }
    form = SectionCreateForm.new(params)
    assert_raises(ActiveRecord::RecordNotFound) do
      form.save
    end
  end
end
