require 'rails_helper'
require 'ostruct'

RSpec.describe 'UnitsController', type: :request do
  describe 'POST /units' do
    let(:create_form) { instance_double(UnitCreateForm) }

    it 'creates unit and returns id' do
      unit = OpenStruct.new(id: 456)
      allow(create_form).to receive(:save).and_return(unit)
      allow(UnitCreateForm).to receive(:new).and_return(create_form)
      post units_url, params: {
        section_id: 1,
        name: 'Unit',
        description: '單元說明',
        content: '內容B',
        idx: 0
      }
      expect(response).to have_http_status(201)
      json = JSON.parse(response.body)
      expect(json['code']).to eq(20100)
      expect(json['data']['id']).to eq(456)
    end

    it "returns error if unit create fails" do
      allow(create_form).to receive(:save).and_return(false)
      allow(create_form).to receive(:errors).and_return(OpenStruct.new(full_messages: ["Name can't be blank"]))
      allow(UnitCreateForm).to receive(:new).and_return(create_form)
      post units_url, params: {
        section_id: 1,
        name: '',
        description: '單元說明',
        content: '內容B',
        idx: 0
      }
      expect(response).to have_http_status(422)
      json = JSON.parse(response.body)
      expect(json['code']).to eq(42200)
    end

    it "returns error if section not found" do
      allow(create_form).to receive(:save).and_raise(ActiveRecord::RecordNotFound)
      allow(UnitCreateForm).to receive(:new).and_return(create_form)
      post units_url, params: {
        section_id: 999,
        name: 'Unit',
        description: '單元說明',
        content: '內容B',
        idx: 0
      }
      expect(response).to have_http_status(400)
      json = JSON.parse(response.body)
      expect(json['code']).to eq(40001)
    end
  end

  describe 'DELETE /units/:id' do
    let(:delete_service) { instance_double(DeleteUnitService) }

    it 'deletes unit and returns success' do
      allow(delete_service).to receive(:call)
      allow(DeleteUnitService).to receive(:new).and_return(delete_service)
      delete unit_url(1)
      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json['code']).to eq(20000)
    end

    it 'returns 400 when unit not found' do
      allow(delete_service).to receive(:call).and_raise(ActiveRecord::RecordNotFound)
      allow(DeleteUnitService).to receive(:new).and_return(delete_service)
      delete unit_url(id: -1)
      expect(response.status).to eq(400)
      expect(response.body).to include('40001')
    end

    it 'returns error if last unit is deleted' do
      allow(delete_service).to receive(:call).and_raise(DeleteUnitService::LastUnitError)
      allow(DeleteUnitService).to receive(:new).and_return(delete_service)
      delete unit_url(1)
      expect(response).to have_http_status(400)
      json = JSON.parse(response.body)
      expect(json['code']).to eq(40002)
    end
  end
end
