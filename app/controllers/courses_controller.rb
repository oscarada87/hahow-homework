class CoursesController < BaseController
  # GET /courses
  def index
    courses = Course.includes(sections: :units).all

    course_json = courses.as_json(
      only: [ :id, :name, :teacher_name, :description ],
      include: {
        sections: {
          only: [ :id, :name, :idx ],
          include: {
            units: {
              only: [ :id, :name, :description, :content, :idx ]
            }
          }
        }
      }
    )
    return_success(status: 200, code: 20_000, data: course_json)
  end

  # GET /courses/:id
  def show
    course = Course.includes(sections: :units).find_by(id: params.require(:id))
    if course.nil?
      return_error(status: 400, code: 40_001, error: StandardError.new("Course not found"), message: "Course not found")
      return
    end

    course_json = course.as_json(
      only: [ :id, :name, :teacher_name, :description ],
      include: {
        sections: {
          only: [ :id, :name, :idx ],
          include: {
            units: {
              only: [ :id, :name, :description, :content, :idx ]
            }
          }
        }
      }
    )
    return_success(status: 200, code: 20_000, data: course_json)
  end

  # POST /courses
  def create
    form = CourseCreateForm.new(course_create_params)
    course = form.save
    if course
      return_success(status: 201, code: 20_100, data: { id: course.id })
    else
      error_message = form.errors.full_messages.join(", ")
      return_error(status: 422, code: 42_200, error: StandardError.new(error_message), message: error_message)
    end
  end

  # PATCH/PUT /courses/:id
  def update
    begin
      form = CourseUpdateForm.new(params.require(:id), course_create_params)
      updated_course = form.save
      if updated_course
        return_success(status: 200, code: 20_000)
      else
        error_message = form.errors.full_messages.join(", ")
        return_error(status: 422, code: 42_200, error: StandardError.new(error_message), message: error_message)
      end
    rescue ActiveRecord::RecordNotFound => e
      return_error(status: 400, code: 40_001, error: e, message: e.message)
    end
  end

  # DELETE /courses/:id
  def destroy
    course = Course.find_by(id: params.require(:id))
    if course.nil?
      return_error(status: 400, code: 40_001, error: StandardError.new("Course not found"), message: "Course not found")
      return
    end
    course.destroy!
    return_success(status: 200, code: 20_000, data: nil)
  end

  private

  def course_create_params
    params.permit(
      :name, :teacher_name, :description,
      sections: [
        :id, :name, :idx,
        units: [
          :id, :name, :description, :content, :idx
        ]
      ]
    )
  end
end
