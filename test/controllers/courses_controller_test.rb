require "test_helper"

class CoursesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course1 = FactoryBot.create(:with_sections_and_units, sections_count: 3, units_count: 2)
    @course2 = FactoryBot.create(:with_sections_and_units, sections_count: 3, units_count: 2)
  end

  test "should get index" do
    get courses_url
    assert_response :success
    data = JSON.parse(@response.body)
    assert_equal 2, data.size
    assert_includes @response.body, @course1.name
  end

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
