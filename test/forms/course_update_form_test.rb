require "test_helper"

class CourseUpdateFormTest < ActiveSupport::TestCase
  def setup
    @course = FactoryBot.create(:with_sections_and_units, sections_count: 2, units_count: 2)
    @section1 = @course.sections[0]
    @section2 = @course.sections[1]
    @unit1 = @section1.units[0]
    @unit2 = @section1.units[1]
  end

  test "成功更新課程基本資料" do
    form = CourseUpdateForm.new(@course.id, { name: "新課程", teacher_name: "新老師", description: "新描述" })
    assert form.save
    @course.reload
    assert_equal "新課程", @course.name
    assert_equal "新老師", @course.teacher_name
    assert_equal "新描述", @course.description
  end

  test "section idx 重複時失敗" do
    params = {
      sections: [
        { id: @section1.id, idx: 1 }
      ]
    }
    form = CourseUpdateForm.new(@course.id, params)
    assert_not form.save
    assert_includes form.errors.full_messages.join, "index of sections is not unique"
  end

  test "unit idx 重複時失敗" do
    params = {
      sections: [
        { id: @section1.id, units: [
          { id: @unit1.id, idx: 1 }
        ] }
      ]
    }
    form = CourseUpdateForm.new(@course.id, params)
    assert_not form.save
    assert_includes form.errors.full_messages.join, "units idx not unique"
  end

  test "section id 不存在時 raise" do
    params = {
      sections: [
        { id: 9999, name: "不存在的章節" }
      ]
    }
    assert_raises ActiveRecord::RecordNotFound do
      CourseUpdateForm.new(@course.id, params).save
    end
  end

  test "unit id 不存在時 raise" do
    params = {
      sections: [
        { id: @section1.id, units: [ { id: 9999, name: "不存在的單元" } ] }
      ]
    }
    assert_raises ActiveRecord::RecordNotFound do
      CourseUpdateForm.new(@course.id, params).save
    end
  end
end
