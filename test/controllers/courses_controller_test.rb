require "test_helper"
require "ostruct"

class BaseCoursesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course1 = FactoryBot.create(:with_sections_and_units, sections_count: 3, units_count: 2)
    @course2 = FactoryBot.create(:with_sections_and_units, sections_count: 3, units_count: 2)
  end
end

class CoursesIndexTest < BaseCoursesControllerTest
  test "should get index" do
    get courses_url
    assert_response :success
    data = JSON.parse(@response.body)
    assert_equal 2, data.size
    assert_includes @response.body, @course1.name
  end
end

class CoursesShowTest < BaseCoursesControllerTest
  test "should show course" do
    get course_url(@course2)
    assert_response :success
    assert_includes @response.body, @course2.name
  end

  test "should return 400 when course not found" do
    get course_url(id: 999_999)
    assert_response 400
    assert_includes @response.body, "Course not found"
    assert_includes @response.body, "40001"
  end
end

class CoursesDeleteTest < BaseCoursesControllerTest
  test "should delete course and its sections and units" do
    section_count = @course1.sections.count
    unit_count = @course1.sections.map { |s| s.units.count }.sum

    assert_difference("Course.count", -1) do
      assert_difference("Section.count", -section_count) do
        assert_difference("Unit.count", -unit_count) do
          delete course_url(@course1)
        end
      end
    end
    assert_response :success
    assert_includes @response.body, "20000"
  end

  test "should return 400 when delete course not found" do
    delete course_url(id: 999_999)
    assert_response 400
    assert_includes @response.body, "Course not found"
    assert_includes @response.body, "40001"
  end
end

class CoursesCreateTest < ActionDispatch::IntegrationTest
  setup do
    @form = Minitest::Mock.new
  end
  test "should create course and return id" do
    course = OpenStruct.new(id: 789)
    @form.expect(:save, course)
    CourseCreateForm.stub(:new, @form) do
      post courses_url, params: {
        name: "新課程",
        teacher_name: "老師A",
        description: "課程說明",
        sections: [
          {
            name: "章節一",
            idx: 0,
            units: [
              {
                name: "單元一",
                description: "單元一說明",
                content: "內容A",
                idx: 0
              }
            ]
          }
        ]
      }
      assert_response 201
      json = JSON.parse(response.body)
      assert_equal 20_100, json["code"]
      assert_equal 789, json["data"]["id"]
    end
  end

  test "should return error if course create fails" do
    @form.expect(:save, false)
    @form.expect(:errors, OpenStruct.new(full_messages: [ "Name can't be blank" ]))
    CourseCreateForm.stub(:new, @form) do
      post courses_url, params: {
        name: "",
        teacher_name: "老師A",
        description: "課程說明"
      }
      assert_response 422
      json = JSON.parse(response.body)
      assert_equal 42_200, json["code"]
      assert_match(/can't be blank/, json["message"])
    end
  end
end
