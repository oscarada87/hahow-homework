# frozen_string_literal: true

class SectionCreateForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :course_id, :name, :idx, :units

  validates :course_id, presence: true
  validates :name, presence: true
  validates :idx, presence: true
  validate :validate_units

  def save
    return false unless valid?
    ActiveRecord::Base.transaction do
      course = Course.find_by(id: course_id)
      raise ActiveRecord::RecordNotFound, "Course not found" if course.nil?
      section = course.sections.create!(name: name, idx: idx)
      if units.present?
        units.each do |unit_params|
          section.units.create!(
            name: unit_params[:name],
            idx: unit_params[:idx],
            content: unit_params[:content],
            description: unit_params[:description]
          )
        end
      end
      section
    end
  end

  private

  def validate_units
    if units.blank? || (units.is_a?(Array) && units.empty?)
      errors.add(:units, "must not be empty")
      return
    end
    unless units.is_a?(Array)
      errors.add(:units, "must be an array")
      return
    end
    unit_idxs = []
    units.each_with_index do |unit, i|
      unless unit[:name].present?
        errors.add(:units, "unit[#{i}].name must be present")
      end
      unless unit[:idx].present?
        errors.add(:units, "unit[#{i}].idx must be present")
      end
      unless unit[:content].present?
        errors.add(:units, "unit[#{i}].content must be present")
      end
      unit_idxs << unit[:idx]
    end
    if unit_idxs.uniq.size != unit_idxs.size
      errors.add(:units, "unit idx must be unique")
    end
  end
end
