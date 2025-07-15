require 'rails_helper'

RSpec.describe SectionCreateForm, type: :form do
  let!(:course) { FactoryBot.create(:with_sections_and_units, sections_count: 1, units_count: 2) }

  describe '#save' do
    context 'with valid params' do
      it 'creates section and units' do
        params = {
          course_id: course.id,
          name: '章節二',
          idx: 1,
          units: [
            { name: '單元一', description: '說明A', content: '內容A', idx: 0 },
            { name: '單元二', description: '說明B', content: '內容B', idx: 1 }
          ]
        }
        form = SectionCreateForm.new(params)
        section = form.save
        expect(section).to be_persisted
        expect(section.name).to eq('章節二')
        expect(section.units.count).to eq(2)
        expect(section.units.first.name).to eq('單元一')
      end
    end

    context 'when name is missing' do
      it 'does not create section' do
        params = {
          course_id: course.id,
          name: '',
          idx: 1,
          units: [ { name: '單元一', description: '說明A', content: '內容A', idx: 0 } ]
        }
        form = SectionCreateForm.new(params)
        expect(form.save).to be_falsey
        expect(form.errors.full_messages.join).to include("Name can't be blank")
      end
    end

    context 'when course is missing' do
      it 'does not create section' do
        params = {
          course_id: nil,
          name: '章節二',
          idx: 1,
          units: [ { name: '單元一', description: '說明A', content: '內容A', idx: 0 } ]
        }
        form = SectionCreateForm.new(params)
        expect(form.save).to be_falsey
        expect(form.errors.full_messages.join).to include("Course can't be blank")
      end
    end

    context 'when units is empty' do
      it 'does not create section' do
        params = {
          course_id: course.id,
          name: '章節二',
          idx: 1,
          units: []
        }
        form = SectionCreateForm.new(params)
        expect(form.save).to be_falsey
        expect(form.errors.full_messages.join).to include('must not be empty')
      end
    end

    context 'when course not found' do
      it 'raises RecordNotFound' do
        params = {
          course_id: -999,
          name: '章節二',
          idx: 1,
          units: [ { name: '單元一', description: '說明A', content: '內容A', idx: 0 } ]
        }
        form = SectionCreateForm.new(params)
        expect { form.save }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when index is not unique' do
      it 'does not create section' do
        params = {
          course_id: course.id,
          name: '章節二',
          idx: 0,
          units: [
            { name: '單元一', description: '說明A', content: '內容A', idx: 0 },
            { name: '單元二', description: '說明B', content: '內容B', idx: 1 }
          ]
        }
        form = SectionCreateForm.new(params)
        expect(form.save).to be_falsey
        expect(form.errors.full_messages.join).to include('must be unique within the same course')
      end
    end
  end
end
