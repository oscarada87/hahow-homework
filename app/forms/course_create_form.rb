# frozen_string_literal: true

class CourseCreateForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :name, :teacher_name, :description, :sections

  validates :name, presence: true
  validates :teacher_name, presence: true
  validate :validate_sections_and_units

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      course = Course.create!(name: name, teacher_name: teacher_name, description: description)
      sections.each do |section_params|
        section = course.sections.create!(
          name: section_params[:name],
          idx: section_params[:idx]
        )
        section_params[:units].each do |unit_params|
          section.units.create!(
            name: unit_params[:name],
            idx: unit_params[:idx],
            content: unit_params[:content],
            description: unit_params[:description]
          )
        end
      end
      course
    end
  end

  private

  def validate_sections_and_units
    if sections.blank? || !sections.is_a?(Array) || sections.empty?
      errors.add(:sections, 'must be present and an array')
      return
    end
    idxs = []
    sections.each_with_index do |section, i|
      unless section[:name].present?
        errors.add(:sections, "section[#{i}].name must be present")
      end
      unless section[:idx].present?
        errors.add(:sections, "section[#{i}].idx must be present")
      end
      idxs << section[:idx]
      units = section[:units]
      if units.blank? || !units.is_a?(Array) || units.empty?
        errors.add(:sections, "section[#{i}].units must be present and an array")
        next
      end
      unit_idxs = []
      units.each_with_index do |unit, j|
        unless unit[:name].present?
          errors.add(:sections, "section[#{i}].units[#{j}].name must be present")
        end
        unless unit[:idx].present?
          errors.add(:sections, "section[#{i}].units[#{j}].idx must be present")
        end
        unless unit[:content].present?
          errors.add(:sections, "section[#{i}].units[#{j}].content must be present")
        end
        unit_idxs << unit[:idx]
      end
      if unit_idxs.uniq.size != unit_idxs.size
        errors.add(:sections, "section[#{i}].units idx must be unique")
      end
    end
    if idxs.uniq.size != idxs.size
      errors.add(:sections, 'section idx must be unique')
    end
  end
end
