require "test_helper"


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
