# frozen_string_literal: true

require "test_helper"

class UnitCreateFormTest < ActiveSupport::TestCase
  def setup
    @course = FactoryBot.create(:with_sections_and_units, sections_count: 1, units_count: 1)
    @section = @course.sections.first
  end

  test "valid params should create unit" do
    params = {
      section_id: @section.id,
      name: "單元二",
      description: "說明A",
      content: "內容A",
      idx: 1
    }
    form = UnitCreateForm.new(params)
    unit = form.save
    assert unit.persisted?
    assert_equal "單元二", unit.name
    assert_equal @section.id, unit.section_id
  end

  test "missing name should not create unit" do
    params = {
      section_id: @section.id,
      name: "",
      description: "說明A",
      content: "內容A",
      idx: 1
    }
    form = UnitCreateForm.new(params)
    refute form.save
    assert_includes form.errors.full_messages.join, "Name can't be blank"
  end

  test "missing section should not create unit" do
    params = {
      section_id: nil,
      name: "單元二",
      description: "說明A",
      content: "內容A",
      idx: 1
    }
    form = UnitCreateForm.new(params)
    refute form.save
    assert_includes form.errors.full_messages.join, "Section can't be blank"
  end

  test "missing content should not create unit" do
    params = {
      section_id: @section.id,
      name: "單元二",
      description: "說明A",
      content: "",
      idx: 1
    }
    form = UnitCreateForm.new(params)
    refute form.save
    assert_includes form.errors.full_messages.join, "Content can't be blank"
  end

  test "should raise error if section not found" do
    params = {
      section_id: -999,
      name: "單元三",
      description: "說明C",
      content: "內容C",
      idx: 2
    }
    form = UnitCreateForm.new(params)
    assert_raises(ActiveRecord::RecordNotFound) do
      form.save
    end
  end

  test "should not create unit if index is not unique" do
    params = {
      section_id: @section.id,
      name: "單元二",
      description: "說明A",
      content: "內容A",
      idx: 0
    }
    form = UnitCreateForm.new(params)
    refute form.save
    assert_includes form.errors.full_messages.join, "must be unique within the same section"
  end
end
