require 'rails_helper'

RSpec.describe CourseUpdateForm, type: :form do
  let!(:course) { FactoryBot.create(:with_sections_and_units, sections_count: 2, units_count: 2) }
  let(:section1) { course.sections[0] }
  let(:section2) { course.sections[1] }
  let(:unit1) { section1.units[0] }
  let(:unit2) { section1.units[1] }

  describe '#save' do
    context 'with valid basic info update' do
      it 'updates course successfully' do
        form = CourseUpdateForm.new(course.id, { 
          name: '新課程', 
          teacher_name: '新老師', 
          description: '新描述' 
        })
        expect(form.save).to be_truthy
        course.reload
        expect(course.name).to eq('新課程')
        expect(course.teacher_name).to eq('新老師')
        expect(course.description).to eq('新描述')
      end
    end

    context 'when section idx is duplicated' do
      it 'fails to save' do
        params = {
          sections: [
            { id: section1.id, idx: 1 }
          ]
        }
        form = CourseUpdateForm.new(course.id, params)
        expect(form.save).to be_falsey
        expect(form.errors.full_messages.join).to include('index of sections is not unique')
      end
    end

    context 'when unit idx is duplicated' do
      it 'fails to save' do
        params = {
          sections: [
            { id: section1.id, units: [
              { id: unit1.id, idx: 1 }
            ] }
          ]
        }
        form = CourseUpdateForm.new(course.id, params)
        expect(form.save).to be_falsey
        expect(form.errors.full_messages.join).to include('units idx not unique')
      end
    end

    context 'when section id does not exist' do
      it 'raises RecordNotFound' do
        params = {
          sections: [
            { id: 9999, name: '不存在的章節' }
          ]
        }
        expect {
          CourseUpdateForm.new(course.id, params).save
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when unit id does not exist' do
      it 'raises RecordNotFound' do
        params = {
          sections: [
            { id: section1.id, units: [ { id: 9999, name: '不存在的單元' } ] }
          ]
        }
        expect {
          CourseUpdateForm.new(course.id, params).save
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
