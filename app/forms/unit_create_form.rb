# frozen_string_literal: true

class UnitCreateForm
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :section_id, :name, :description, :content, :idx

  validates :section_id, presence: true
  validates :name, presence: true
  validates :idx, presence: true
  validates :content, presence: true

  def save
    return false unless valid?
    ActiveRecord::Base.transaction do
      section = Section.includes(:units).find_by(id: section_id)
      raise ActiveRecord::RecordNotFound, 'Section not found' if section.nil?
      if section.units.where(idx: idx).exists?
        errors.add(:idx, 'must be unique within the same section')
        return false
      end
      unit = section.units.create!(
        name: name,
        description: description,
        content: content,
        idx: idx
      )
      unit
    end
  end
end
