class SectionsController < BaseController
  # POST /sections
  def create
    form = SectionCreateForm.new(section_create_params)
    begin
      section = form.save
      if section
        return_success(status: 201, code: 20_100, data: { id: section.id })
      else
        error_message = form.errors.full_messages.join(', ')
        return_error(status: 422, code: 42_200, error: StandardError.new(error_message), message: error_message)
      end
    rescue ActiveRecord::RecordNotFound => e
      return_error(status: 400, code: 40_001, error: e, message: e.message)
    end
  end

  # DELETE /sections/:id
  def destroy
    begin
      service = DeleteSectionService.new(params.require(:id))
      service.call
      return_success(status: 200, code: 20_000, data: nil)
    rescue ActiveRecord::RecordNotFound => e
      return_error(status: 400, code: 40_001, error: e, message: e.message)
    rescue DeleteSectionService::LastSectionError => e
      return_error(status: 400, code: 40_002, error: e, message: e.message)
    end
  end

  private

  def section_create_params
    params.permit(:course_id, :name, :idx, units: [ :name, :description, :content, :idx ])
  end
end
