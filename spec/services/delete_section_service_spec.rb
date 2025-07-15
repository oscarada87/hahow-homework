require 'rails_helper'

RSpec.describe DeleteSectionService, type: :service do
  let!(:course) { FactoryBot.create(:with_sections_and_units, sections_count: 2, units_count: 2) }
  let(:section1) { course.sections.first }
  let(:section2) { course.sections.last }

  describe '#call' do
    context 'when section is not the last one' do
      it 'deletes the section and its units' do
        units = section1.units.pluck(:id)
        service = DeleteSectionService.new(section1.id)
        
        expect { service.call }.to change(Section, :count).by(-1)
        expect(Section.find_by(id: section1.id)).to be_nil
        
        units.each do |unit_id|
          expect(Unit.find_by(id: unit_id)).to be_nil, "Unit ##{unit_id} should be deleted when section is deleted"
        end
      end
    end

    context 'when section is the last one' do
      it 'raises LastSectionError' do
        section2.destroy!
        service = DeleteSectionService.new(section1.id)
        
        expect { service.call }.to raise_error(DeleteSectionService::LastSectionError)
        expect(Section.find_by(id: section1.id)).to be_present
      end
    end

    context 'when section does not exist' do
      it 'raises RecordNotFound' do
        service = DeleteSectionService.new(-1)
        
        expect { service.call }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
