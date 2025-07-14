class SectionsController < BaseController
  # POST /sections
  def create
    form = SectionCreateForm.new(section_create_params)
    begin
      if form.save
        return_success(status: 201, code: 20_100, data: { id: form.section.id })
      else
        return_error(status: 422, code: 42_200, error: StandardError.new(form.errors.full_messages.join(", ")), message: form.errors.full_messages.join(", "))
      end
    rescue ActiveRecord::RecordNotFound => e
      return_error(status: 400, code: 40_001, error: e, message: "Course not found")
    end
  end

  # DELETE /sections/:id
  def destroy
    section = Section.find_by(id: params.require(:id))
    if section.nil?
      return_error(status: 400, code: 41_001, error: StandardError.new("Section not found"), message: "Section not found")
      return
    end
    section.destroy!
    return_success(status: 200, code: 21_200, data: nil)
  end

  private

  def section_create_params
    params.permit(:course_id, :name, :idx, units: [ :name, :description, :content, :idx ])
  end
end
