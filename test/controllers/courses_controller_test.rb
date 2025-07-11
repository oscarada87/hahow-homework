require "test_helper"

class CoursesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course1 = FactoryBot.create(:with_sections_and_units, sections_count: 3, units_count: 2)
    @course2 = FactoryBot.create(:with_sections_and_units, sections_count: 3, units_count: 2)
  end

  test "should get index" do
    get courses_url
    assert_response :success
    assert_includes @response.body, @course1.name
  end

  test "should show course" do
    get course_url(@course2)
    assert_response :success
    assert_includes @response.body, @course2.name
  end
end
