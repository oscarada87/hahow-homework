class UnitsController < BaseController
  # POST /units
  def create
    form = UnitCreateForm.new(unit_create_params)
    begin
      unit = form.save
      if unit
        return_success(status: 201, code: 20_100, data: { id: unit.id })
      else
        error_message = form.errors.full_messages.join(', ')
        return_error(status: 422, code: 42_200, error: StandardError.new(), message: error_message)
      end
    rescue ActiveRecord::RecordNotFound => e
      return_error(status: 400, code: 40_001, error: e, message: 'Section not found')
    end
  end

  # DELETE /units/:id
  def destroy
    begin
      service = DeleteUnitService.new(params.require(:id))
      service.call
      return_success(status: 200, code: 20_000, data: nil)
    rescue DeleteUnitService::LastUnitError => e
      return_error(status: 400, code: 40_002, error: e, message: e.message)
    rescue ActiveRecord::RecordNotFound => e
      return_error(status: 400, code: 40_001, error: e, message: 'Unit not found')
    end
  end

  private

  def unit_create_params
    params.permit(:section_id, :name, :description, :content, :idx)
  end
end
