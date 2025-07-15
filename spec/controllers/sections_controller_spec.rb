require 'rails_helper'
require 'ostruct'

RSpec.describe 'SectionsController', type: :request do
  describe 'POST /sections' do
    let(:create_form) { instance_double(SectionCreateForm) }
    it 'creates section and returns id' do
      section = OpenStruct.new(id: 123)
      allow(create_form).to receive(:save).and_return(section)
      allow(SectionCreateForm).to receive(:new).and_return(create_form)
      post sections_url, params: {
        course_id: 1,
        name: 'Section',
        idx: 1,
        units: [
          {
            name: '單元一',
            description: '單元一說明',
            content: '內容A',
            idx: 0
          }
        ]
      }
      expect(response).to have_http_status(201)
      json = JSON.parse(response.body)
      expect(json['code']).to eq(20100)
      expect(json['data']['id']).to eq(123)
    end

    it "returns error if section create fails" do
      allow(create_form).to receive(:save).and_return(false)
      allow(create_form).to receive(:errors).and_return(OpenStruct.new(full_messages: [ "Name can't be blank" ]))
      allow(SectionCreateForm).to receive(:new).and_return(create_form)
      post sections_url, params: {
        course_id: 1,
        idx: 1,
        units: [
          {
            name: '單元一',
            description: '單元一說明',
            content: '內容A',
            idx: 0
          }
        ]
      }
      expect(response).to have_http_status(422)
      json = JSON.parse(response.body)
      expect(json['code']).to eq(42200)
    end

    it "returns error if course not found" do
      allow(create_form).to receive(:save).and_raise(ActiveRecord::RecordNotFound)
      allow(SectionCreateForm).to receive(:new).and_return(create_form)
      post sections_url, params: {
        course_id: -1,
        name: 'Section',
        idx: 1,
        units: [
          {
            name: '單元一',
            description: '單元一說明',
            content: '內容A',
            idx: 0
          }
        ]
      }
      expect(response).to have_http_status(400)
      json = JSON.parse(response.body)
      expect(json['code']).to eq(40001)
    end
  end

  describe 'DELETE /sections/:id' do
    let(:delete_service) { instance_double(DeleteSectionService) }

    it 'deletes section successfully' do
      allow(delete_service).to receive(:call)
      allow(DeleteSectionService).to receive(:new).and_return(delete_service)
      delete section_url(1)
      expect(response).to have_http_status(200)
      json = JSON.parse(response.body)
      expect(json['code']).to eq(20000)
    end

    it 'returns error if section not found' do
      allow(delete_service).to receive(:call).and_raise(ActiveRecord::RecordNotFound)
      allow(DeleteSectionService).to receive(:new).and_return(delete_service)
      delete section_url(-1)
      expect(response).to have_http_status(400)
      json = JSON.parse(response.body)
      expect(json['code']).to eq(40001)
    end

    it 'returns error if last section is deleted' do
      allow(delete_service).to receive(:call).and_raise(DeleteSectionService::LastSectionError)
      allow(DeleteSectionService).to receive(:new).and_return(delete_service)
      delete section_url(1)
      expect(response).to have_http_status(400)
      json = JSON.parse(response.body)
      expect(json['code']).to eq(40002)
    end
  end
end
