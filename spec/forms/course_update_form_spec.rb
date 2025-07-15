require 'rails_helper'

RSpec.describe CourseUpdateForm, type: :form do
  let!(:course) { FactoryBot.create(:with_sections_and_units, sections_count: 2, units_count: 2) }
  let(:section1) { course.sections[0] }
  let(:section2) { course.sections[1] }
  let(:unit1) { section1.units[0] }
  let(:unit2) { section1.units[1] }

  describe '#save' do
    context 'with valid basic info update' do
      it 'updates course, section, unit successfully' do
        form = CourseUpdateForm.new(course.id, {
          name: '新課程',
          teacher_name: '新老師',
          description: '新描述',
          sections: [
            {
              id: section1.id,
              name: '更新的章節一',
              idx: 0,
              units: [
                { id: unit1.id, name: '更新的單元一', description: '更新的描述', content: '更新的內容', idx: 0 },
                { id: unit2.id, name: '更新的單元二', description: '更新的描述', content: '更新的內容', idx: 1 }
              ]
            }
          ]
        })
        expect(form.save).to be_truthy
        course.reload
        expect(course.name).to eq('新課程')
        expect(course.teacher_name).to eq('新老師')
        expect(course.description).to eq('新描述')

        updated_section = course.sections.find(section1.id)
        expect(updated_section.name).to eq('更新的章節一')

        updated_unit1 = updated_section.units.find(unit1.id)
        updated_unit2 = updated_section.units.find(unit2.id)
        expect(updated_unit1.name).to eq('更新的單元一')
        expect(updated_unit2.name).to eq('更新的單元二')
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
            { id: -1, name: '不存在的章節' }
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
            { id: section1.id, units: [ { id: -1, name: '不存在的單元' } ] }
          ]
        }
        expect {
          CourseUpdateForm.new(course.id, params).save
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when course does not exist' do
      it 'raises RecordNotFound' do
        params = {
          name: '新課程名稱',
          teacher_name: '新老師',
          description: '新描述'
        }
        expect {
          CourseUpdateForm.new(-1, params).save
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
