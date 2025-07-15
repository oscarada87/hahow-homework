require 'rails_helper'

RSpec.describe UnitCreateForm, type: :form do
  let!(:course) { FactoryBot.create(:with_sections_and_units, sections_count: 1, units_count: 1) }
  let(:section) { course.sections.first }

  describe '#save' do
    context 'with valid params' do
      it 'creates unit' do
        params = {
          section_id: section.id,
          name: '單元二',
          description: '說明A',
          content: '內容A',
          idx: 1
        }
        form = UnitCreateForm.new(params)
        unit = form.save
        expect(unit).to be_persisted
        expect(unit.name).to eq('單元二')
        expect(unit.section_id).to eq(section.id)
      end
    end

    context 'when name is missing' do
      it 'does not create unit' do
        params = {
          section_id: section.id,
          name: '',
          description: '說明A',
          content: '內容A',
          idx: 1
        }
        form = UnitCreateForm.new(params)
        expect(form.save).to be_falsey
        expect(form.errors.full_messages.join).to include("Name can't be blank")
      end
    end

    context 'when section is missing' do
      it 'does not create unit' do
        params = {
          section_id: nil,
          name: '單元二',
          description: '說明A',
          content: '內容A',
          idx: 1
        }
        form = UnitCreateForm.new(params)
        expect(form.save).to be_falsey
        expect(form.errors.full_messages.join).to include("Section can't be blank")
      end
    end

    context 'when content is missing' do
      it 'does not create unit' do
        params = {
          section_id: section.id,
          name: '單元二',
          description: '說明A',
          content: '',
          idx: 1
        }
        form = UnitCreateForm.new(params)
        expect(form.save).to be_falsey
        expect(form.errors.full_messages.join).to include("Content can't be blank")
      end
    end

    context 'when section not found' do
      it 'raises RecordNotFound' do
        params = {
          section_id: -999,
          name: '單元三',
          description: '說明C',
          content: '內容C',
          idx: 2
        }
        form = UnitCreateForm.new(params)
        expect { form.save }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'when index is not unique' do
      it 'does not create unit' do
        params = {
          section_id: section.id,
          name: '單元二',
          description: '說明A',
          content: '內容A',
          idx: 0
        }
        form = UnitCreateForm.new(params)
        expect(form.save).to be_falsey
        expect(form.errors.full_messages.join).to include('must be unique within the same section')
      end
    end
  end
end
