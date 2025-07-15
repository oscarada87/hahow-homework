# frozen_string_literal: true

class DeleteUnitService
  class LastUnitError < StandardError; end

  def initialize(unit_id)
    @unit = Unit.find_by(id: unit_id)
  end

  def call
    raise ActiveRecord::RecordNotFound, 'Unit not found' if @unit.nil?
    section = @unit.section
    Unit.transaction do
      section.reload
      if section.units.count == 1
        raise LastUnitError, 'Cannot delete the last unit of the section'
      end
      @unit.destroy!
    end
    true
  end
end
