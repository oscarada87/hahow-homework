require 'rails_helper'

RSpec.describe DeleteUnitService, type: :service do
  let!(:course) { FactoryBot.create(:with_sections_and_units, sections_count: 1, units_count: 2) }
  let(:section) { course.sections.first }
  let(:unit1) { section.units.first }
  let(:unit2) { section.units.last }

  describe '#call' do
    context 'when unit is not the last one' do
      it 'deletes the unit' do
        service = DeleteUnitService.new(unit1.id)
        
        expect { service.call }.to change(Unit, :count).by(-1)
        expect(Unit.find_by(id: unit1.id)).to be_nil
      end
    end

    context 'when unit is the last one' do
      it 'raises LastUnitError' do
        unit2.destroy!
        service = DeleteUnitService.new(unit1.id)
        
        expect { service.call }.to raise_error(DeleteUnitService::LastUnitError)
        expect(Unit.find_by(id: unit1.id)).to be_present
      end
    end

    context 'when unit does not exist' do
      it 'raises RecordNotFound' do
        service = DeleteUnitService.new(-1)
        
        expect { service.call }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
