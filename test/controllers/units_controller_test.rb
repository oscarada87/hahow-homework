# frozen_string_literal: true

require "test_helper"
require "ostruct"

class UnitsControllerCreateTest < ActionDispatch::IntegrationTest
  setup do
    @unit_id = "1"
    @form = Minitest::Mock.new
  end

  test "should create unit and return id" do
    unit = OpenStruct.new(id: 456)
    @form.expect(:save, unit)
    UnitCreateForm.stub(:new, @form) do
      post units_url, params: {
        section_id: 1,
        name: "Unit",
        description: "單元說明",
        content: "內容B",
        idx: 0
      }
      assert_response 201
      json = JSON.parse(response.body)
      assert_equal 20_100, json["code"]
      assert_equal 456, json["data"]["id"]
    end
  end

  test "should return error if unit create fails" do
    @form.expect(:save, false)
    @form.expect(:errors, OpenStruct.new(full_messages: [ "Name can't be blank" ]))
    UnitCreateForm.stub(:new, @form) do
      post units_url, params: {
        section_id: 1,
        name: "",
        description: "單元說明",
        content: "內容B",
        idx: 0
      }
      assert_response 422
      json = JSON.parse(response.body)
      assert_equal 42_200, json["code"]
    end
  end

  test "should return error if section not found" do
    @form.expect(:save, nil) { raise ActiveRecord::RecordNotFound }
    UnitCreateForm.stub(:new, @form) do
      post units_url, params: {
        section_id: -1,
        name: "Unit",
        description: "單元說明",
        content: "內容B",
        idx: 0
      }
      assert_response 400
      json = JSON.parse(response.body)
      assert_equal 40_001, json["code"]
    end
  end
end

class UnitsControllerDestroyTest < ActionDispatch::IntegrationTest
  setup do
    @unit_id = "1"
    @service = Minitest::Mock.new
  end

  test "should call service and return success" do
    @service.expect(:call, true)
    DeleteUnitService.stub(:new, ->(_id) { @service }) do
      delete unit_url(@unit_id)
      assert_response :success
    end
  end

  test "should handle not found error" do
    @service.expect(:call, nil) { raise ActiveRecord::RecordNotFound }
    DeleteUnitService.stub(:new, ->(_id) { @service }) do
      delete unit_url(@unit_id)
      assert_response 400
      assert_includes @response.body, "41002"
    end
  end

  test "should handle last unit error" do
    @service.expect(:call, nil) { raise DeleteUnitService::LastUnitError }
    DeleteUnitService.stub(:new, ->(_id) { @service }) do
      delete unit_url(@unit_id)
      assert_response 400
      assert_includes @response.body, "41003"
    end
  end
end
