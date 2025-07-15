require 'rails_helper'

RSpec.describe 'CoursesController', type: :request do
  let!(:course1) { FactoryBot.create(:with_sections_and_units, sections_count: 3, units_count: 2) }
  let!(:course2) { FactoryBot.create(:with_sections_and_units, sections_count: 3, units_count: 2) }

  describe 'GET /courses' do
    it 'returns all courses' do
      get courses_url
      expect(response).to have_http_status(:success)
      data = JSON.parse(response.body)
      expect(data.size).to eq(2)
      expect(response.body).to include(course1.name)
    end
  end

  describe 'GET /courses/:id' do
    it 'returns the course' do
      get course_url(course2)
      expect(response).to have_http_status(:success)
      expect(response.body).to include(course2.name)
    end

    it 'returns 400 when course not found' do
      get course_url(id: 999_999)
      expect(response.status).to eq(400)
      expect(response.body).to include('Course not found')
      expect(response.body).to include('40001')
    end
  end

  describe 'DELETE /courses/:id' do
    it 'deletes course and its sections and units' do
      section_count = course1.sections.count
      unit_count = course1.sections.map { |s| s.units.count }.sum
      expect {
        expect {
          expect {
            delete course_url(course1)
          }.to change(Unit, :count).by(-unit_count)
        }.to change(Section, :count).by(-section_count)
      }.to change(Course, :count).by(-1)
      expect(response).to have_http_status(:success)
      expect(response.body).to include('20000')
    end

    it 'returns 400 when delete course not found' do
      delete course_url(id: 999_999)
      expect(response.status).to eq(400)
      expect(response.body).to include('Course not found')
      expect(response.body).to include('40001')
    end
  end

  describe 'POST /courses' do
    let(:form) { instance_double(CourseCreateForm) }

    it 'creates course and returns id' do
      course = OpenStruct.new(id: 789)
      allow(form).to receive(:save).and_return(course)
      allow(CourseCreateForm).to receive(:new).and_return(form)
      post courses_url, params: {
        name: '新課程',
        teacher_name: '老師A',
        description: '課程說明',
        sections: [
          {
            name: '章節一',
            idx: 0,
            units: [
              {
                name: '單元一',
                description: '單元一說明',
                content: '內容A',
                idx: 0
              }
            ]
          }
        ]
      }
      expect(response).to have_http_status(201)
      json = JSON.parse(response.body)
      expect(json['code']).to eq(20100)
      expect(json['data']['id']).to eq(789)
    end

    it 'returns error if course create fails' do
      allow(form).to receive(:save).and_return(false)
      allow(form).to receive(:errors).and_return(OpenStruct.new(full_messages: ["Name can't be blank"]))
      allow(CourseCreateForm).to receive(:new).and_return(form)
      post courses_url, params: {
        name: '',
        teacher_name: '老師A',
        description: '課程說明'
      }
      expect(response).to have_http_status(422)
      json = JSON.parse(response.body)
      expect(json['code']).to eq(42200)
      expect(json['message']).to match(/can't be blank/)
    end
  end

  describe 'PATCH /courses/:id' do
    let(:form) { instance_double(CourseUpdateForm) }
    let(:course_id) { '1' }

    it 'updates course basic info' do
      allow(form).to receive(:save).and_return(true)
      allow(CourseUpdateForm).to receive(:new).and_return(form)
      patch course_url(course_id), params: {
        name: '新課程名',
        teacher_name: '新老師',
        description: '新描述'
      }
      expect(response).to have_http_status(:success)
      json = JSON.parse(response.body)
      expect(json['code']).to eq(20000)
    end

    it 'returns error if params error' do
      allow(form).to receive(:save).and_return(false)
      allow(form).to receive(:errors).and_return(OpenStruct.new(full_messages: ["Name can't be blank"]))
      allow(CourseUpdateForm).to receive(:new).and_return(form)
      patch course_url(course_id), params: { name: '' }
      expect(response).to have_http_status(422)
      json = JSON.parse(response.body)
      expect(json['code']).to eq(42200)
    end

    it 'returns 400 if course not found' do
      allow(form).to receive(:save).and_raise(ActiveRecord::RecordNotFound)
      allow(CourseUpdateForm).to receive(:new).and_return(form)
      patch course_url(id: 999_999), params: { name: 'X' }
      expect(response).to have_http_status(400)
      json = JSON.parse(response.body)
      expect(json['code']).to eq(40001)
    end
  end
end
