class UnitsController < BaseController
  # POST /units
  def create
    form = UnitCreateForm.new(unit_create_params)
    begin
      if form.save
        return_success(status: 201, code: 20_100, data: { id: form.unit.id })
      else
        return_error(status: 422, code: 42_200, error: StandardError.new(form.errors.full_messages.join(", ")), message: form.errors.full_messages.join(", "))
      end
    rescue ActiveRecord::RecordNotFound => e
      return_error(status: 400, code: 40_001, error: e, message: "Section not found")
    end
  end

  # DELETE /units/:id
  def destroy
    unit = Unit.find_by(id: params.require(:id))
    if unit.nil?
      return_error(status: 400, code: 41_002, error: StandardError.new("Unit not found"), message: "Unit not found")
      return
    end
    unit.destroy!
    return_success(status: 200, code: 22_200, data: nil)
  end

  private

  def unit_create_params
    params.permit(:section_id, :name, :description, :content, :idx)
  end
end
