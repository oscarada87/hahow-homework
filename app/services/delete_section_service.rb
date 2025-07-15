# frozen_string_literal: true

class DeleteSectionService
  class LastSectionError < StandardError; end

  def initialize(section_id)
    @section = Section.find_by(id: section_id)
  end

  def call
    raise ActiveRecord::RecordNotFound, 'Section not found' if @section.nil?
    course = @section.course
    Section.transaction do
      course.reload
      if course.sections.count == 1
        raise LastSectionError, 'Cannot delete the last section of the course'
      end
      @section.destroy!
    end
    true
  end
end
