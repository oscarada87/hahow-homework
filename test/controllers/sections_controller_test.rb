# frozen_string_literal: true

require "test_helper"
require "ostruct"

class SectionsControllerCreateTest < ActionDispatch::IntegrationTest
  setup do
    @section_id = "1"
    @form = Minitest::Mock.new
  end

  test "should create section and return id" do
    section = OpenStruct.new(id: 123)
    @form.expect(:save, section)
    SectionCreateForm.stub(:new, @form) do
      post sections_url, params: {
        course_id: 1,
        name: "Section",
        idx: 1,
        units: [
          {
            name: "單元一",
            description: "單元一說明",
            content: "內容A",
            idx: 0
          }
        ]
      }
      assert_response 201
      json = JSON.parse(response.body)
      assert_equal 20_100, json["code"]
      assert_equal 123, json["data"]["id"]
    end
  end

  test "should return error if section create fails" do
    @form.expect(:save, false)
    @form.expect(:errors, OpenStruct.new(full_messages: [ "Name can't be blank" ]))
    SectionCreateForm.stub(:new, @form) do
      post sections_url,  params: {
        course_id: 1,
        idx: 1,
        units: [
          {
            name: "單元一",
            description: "單元一說明",
            content: "內容A",
            idx: 0
          }
        ]
      }
      assert_response 422
      json = JSON.parse(response.body)
      assert_equal 42_200, json["code"]
    end
  end

  test "should return error if course not found" do
    @form.expect(:save, nil) { raise ActiveRecord::RecordNotFound }
    SectionCreateForm.stub(:new, @form) do
      post sections_url, params: { course_id: -1, name: "Section", idx: 1 }
      assert_response 400
      json = JSON.parse(response.body)
      assert_equal 40_001, json["code"]
    end
  end
end

class SectionsControllerDestroyTest < ActionDispatch::IntegrationTest
  setup do
    @section_id = "1"
    @service = Minitest::Mock.new
  end

  test "should call service and return success" do
    @service.expect(:call, true)
    DeleteSectionService.stub(:new, ->(_id) { @service }) do
      delete section_url(@section_id)
      assert_response :success
    end
  end

  test "should handle not found error" do
    @service.expect(:call, nil) { raise ActiveRecord::RecordNotFound }
    DeleteSectionService.stub(:new, ->(_id) { @service }) do
      delete section_url(@section_id)
      assert_response 400
      assert_includes @response.body, "40001"
    end
  end

  test "should handle last section error" do
    @service.expect(:call, nil) { raise DeleteSectionService::LastSectionError }
    DeleteSectionService.stub(:new, ->(_id) { @service }) do
      delete section_url(@section_id)
      assert_response 400
      assert_includes @response.body, "40002"
    end
  end
end
