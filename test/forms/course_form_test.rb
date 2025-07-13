require "test_helper"

class CourseFormTest < ActiveSupport::TestCase
  def valid_params
    {
      name: "Ruby 101",
      teacher_name: "王大明",
      description: "這是一個 Ruby 課程",
      sections: [
        {
          name: "第一章",
          idx: 0,
          units: [
            {
              name: "單元一",
              description: "單元一說明",
              content: "內容A",
              idx: 0
            },
            {
              name: "單元二",
              content: "內容B",
              idx: 1
            }
          ]
        },
        {
          name: "第二章",
          idx: 1,
          units: [
            {
              name: "單元一",
              description: "單元一說明",
              content: "內容C",
              idx: 0
            }
          ]
        }
      ]
    }
  end

  test "valid course form can save" do
    form = CourseForm.new(valid_params)
    assert form.valid?
    assert form.save
    course = Course.last
    assert_equal "Ruby 101", course.name
    assert_equal 2, course.sections.count
    assert_equal 2, course.sections.first.units.count
  end

  test "invalid without name" do
    params = valid_params.merge(name: nil)
    form = CourseForm.new(params)
    assert_not form.valid?
    assert_includes form.errors[:name], "can't be blank"
  end

  test "invalid without teacher_name" do
    params = valid_params.merge(teacher_name: nil)
    form = CourseForm.new(params)
    assert_not form.valid?
    assert_includes form.errors[:teacher_name], "can't be blank"
  end

  test "invalid if sections is not array" do
    params = valid_params.merge(sections: nil)
    form = CourseForm.new(params)
    assert_not form.valid?
    assert_includes form.errors[:sections], "must be present and an array"
  end

  test "invalid if sections is empty" do
    params = valid_params.merge(sections: [])
    form = CourseForm.new(params)
    assert_not form.valid?
    assert_includes form.errors[:sections], "must be present and an array"
  end

  test "invalid if units missing in section" do
    params = valid_params.dup
    params[:sections][0].delete(:units)
    form = CourseForm.new(params)
    assert_not form.valid?
    assert_match /units must be present and an array/, form.errors[:sections].join
  end

  test "invalid if section idx not unique" do
    params = valid_params.dup
    params[:sections][1][:idx] = 0
    form = CourseForm.new(params)
    assert_not form.valid?
    assert_match /section idx must be unique/, form.errors[:sections].join
  end

  test "invalid if unit idx not unique in section" do
    params = valid_params.dup
    params[:sections][0][:units][1][:idx] = 0
    form = CourseForm.new(params)
    assert_not form.valid?
    assert_match /units idx must be unique/, form.errors[:sections].join
  end

  test "invalid if unit missing required fields" do
    params = valid_params.dup
    params[:sections][0][:units][0][:name] = nil
    params[:sections][0][:units][0][:content] = nil
    form = CourseForm.new(params)
    assert_not form.valid?
    assert_match /name must be present/, form.errors[:sections].join
    assert_match /content must be present/, form.errors[:sections].join
  end
end
