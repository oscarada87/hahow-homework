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
    # @course = Course.new(course_params)

    # if @course.save
    #   render json: @course, status: :created
    # else
    #   render json: @course.errors, status: :unprocessable_entity
    # end
  end

  # PATCH/PUT /courses/:id
  def update
    # if @course.update(course_params)
    #   render json: @course
    # else
    #   render json: @course.errors, status: :unprocessable_entity
    # end
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
end
