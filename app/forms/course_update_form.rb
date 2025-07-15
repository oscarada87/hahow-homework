# frozen_string_literal: true

class CourseUpdateForm
  include ActiveModel::Model

  attr_accessor :course, :name, :teacher_name, :description, :sections

  validates :course, presence: true
  validates :name, presence: true
  validates :teacher_name, presence: true

  def initialize(id, params)
    @course = Course.find_by(id: id)
    raise ActiveRecord::RecordNotFound, 'Course not found' unless @course
    @name = params[:name] || @course.name
    @teacher_name = params[:teacher_name] || @course.teacher_name
    @description = params[:description] || @course.description
    @sections = params[:sections]
  end

  def save
    return false unless valid?

    # 檢查 sections 的 idx 是否重複
    if sections.present?
      input_section_idxs = sections.select { |s| !s[:idx].nil? }.map { |s| { id: s[:id], idx: s[:idx] } }
      db_section_idxs = course.sections.pluck(:idx)
      update_ids = input_section_idxs.map { |s| s[:id] }.compact
      all_section_idxs = course.sections.where.not(id: update_ids).pluck(:idx) + input_section_idxs.map { |s| s[:idx] }
      if all_section_idxs.size != all_section_idxs.uniq.size
        errors.add(:base, 'index of sections is not unique')
        return false
      end

      # 檢查每個 section 的 units 的 idx 是否重複
      sections.each do |section_params|
        next unless section_params[:units].present? && section_params[:id]
        section = course.sections.find_by(id: section_params[:id])
        next unless section
        input_unit_idxs = section_params[:units].select { |u| !u[:idx].nil? }.map { |u| { id: u[:id], idx: u[:idx] } }
        update_unit_ids = input_unit_idxs.map { |u| u[:id] }.compact
        db_unit_idxs = section.units.where.not(id: update_unit_ids).pluck(:idx)
        all_unit_idxs = db_unit_idxs + input_unit_idxs.map { |u| u[:idx] }
        if all_unit_idxs.size != all_unit_idxs.uniq.size
          errors.add(:base, "section id=#{section_params[:id]} of units idx not unique")
          return false
        end
      end
    end

    ActiveRecord::Base.transaction do
      course.update!(name: name, teacher_name: teacher_name, description: description)

      if sections.present?
        sections.each do |section_params|
          raise ActiveRecord::RecordNotFound, 'Section not found' unless section_params[:id]
          section = course.sections.find_by(id: section_params[:id])
          raise ActiveRecord::RecordNotFound, 'Section not found' unless section
          section.name = section_params[:name] if section_params[:name]
          section.idx = section_params[:idx] if section_params[:idx]
          section.save!

          if section_params[:units].present?
            section_params[:units].each do |unit_params|
              raise ActiveRecord::RecordNotFound, 'Unit not found' unless unit_params[:id]
              unit = section.units.find_by(id: unit_params[:id])
              raise ActiveRecord::RecordNotFound, 'Unit not found' unless unit
              unit.name = unit_params[:name] if unit_params[:name]
              unit.description = unit_params[:description] if unit_params[:description]
              unit.content = unit_params[:content] if unit_params[:content]
              unit.idx = unit_params[:idx] if unit_params[:idx]
              unit.save!
            end
          end
        end
      end
    end
    course
  end
end
