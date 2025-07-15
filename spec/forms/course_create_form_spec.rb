require 'rails_helper'

RSpec.describe CourseCreateForm, type: :form do
  let(:valid_params) do
    {
      name: 'Ruby 101',
      teacher_name: '王大明',
      description: '這是一個 Ruby 課程',
      sections: [
        {
          name: '第一章',
          idx: 0,
          units: [
            {
              name: '單元一',
              description: '單元一說明',
              content: '內容A',
              idx: 0
            },
            {
              name: '單元二',
              content: '內容B',
              idx: 1
            }
          ]
        },
        {
          name: '第二章',
          idx: 1,
          units: [
            {
              name: '單元一',
              description: '單元一說明',
              content: '內容C',
              idx: 0
            }
          ]
        }
      ]
    }
  end

  describe '#save' do
    context 'with valid params' do
      it 'creates course with sections and units' do
        form = CourseCreateForm.new(valid_params)
        expect(form).to be_valid
        expect(form.save).to be_truthy
        course = Course.last
        expect(course.name).to eq('Ruby 101')
        expect(course.sections.count).to eq(2)
        expect(course.sections.first.units.count).to eq(2)
      end
    end

    context 'when name is missing' do
      it 'is invalid' do
        params = valid_params.merge(name: nil)
        form = CourseCreateForm.new(params)
        expect(form).not_to be_valid
        expect(form.errors[:name]).to include("can't be blank")
      end
    end

    context 'when teacher_name is missing' do
      it 'is invalid' do
        params = valid_params.merge(teacher_name: nil)
        form = CourseCreateForm.new(params)
        expect(form).not_to be_valid
        expect(form.errors[:teacher_name]).to include("can't be blank")
      end
    end

    context 'when sections is not array' do
      it 'is invalid' do
        params = valid_params.merge(sections: nil)
        form = CourseCreateForm.new(params)
        expect(form).not_to be_valid
        expect(form.errors[:sections]).to include('must be present and an array')
      end
    end

    context 'when sections is empty' do
      it 'is invalid' do
        params = valid_params.merge(sections: [])
        form = CourseCreateForm.new(params)
        expect(form).not_to be_valid
        expect(form.errors[:sections]).to include('must be present and an array')
      end
    end

    context 'when units missing in section' do
      it 'is invalid' do
        params = valid_params.dup
        params[:sections][0].delete(:units)
        form = CourseCreateForm.new(params)
        expect(form).not_to be_valid
        expect(form.errors[:sections].join).to match(/units must be present and an array/)
      end
    end

    context 'when section idx not unique' do
      it 'is invalid' do
        params = valid_params.dup
        params[:sections][1][:idx] = 0
        form = CourseCreateForm.new(params)
        expect(form).not_to be_valid
        expect(form.errors[:sections].join).to match(/section idx must be unique/)
      end
    end

    context 'when unit idx not unique in section' do
      it 'is invalid' do
        params = valid_params.dup
        params[:sections][0][:units][1][:idx] = 0
        form = CourseCreateForm.new(params)
        expect(form).not_to be_valid
        expect(form.errors[:sections].join).to match(/units idx must be unique/)
      end
    end

    context 'when unit missing required fields' do
      it 'is invalid' do
        params = valid_params.dup
        params[:sections][0][:units][0][:name] = nil
        params[:sections][0][:units][0][:content] = nil
        form = CourseCreateForm.new(params)
        expect(form).not_to be_valid
        expect(form.errors[:sections].join).to match(/name must be present/)
        expect(form.errors[:sections].join).to match(/content must be present/)
      end
    end
  end
end
