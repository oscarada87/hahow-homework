class CoursesController < ApplicationController
  before_action :set_course, only: [ :show, :update, :destroy ]

  # GET /courses
  def index
    courses = Course.includes(sections: :units).all

    render json: courses.as_json(
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
  end

  # GET /courses/:id
  def show
    render json: @course.as_json(
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
  end

  # POST /courses
  def create
    @course = Course.new(course_params)

    if @course.save
      render json: @course, status: :created
    else
      render json: @course.errors, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /courses/:id
  def update
    if @course.update(course_params)
      render json: @course
    else
      render json: @course.errors, status: :unprocessable_entity
    end
  end

  # DELETE /courses/:id
  def destroy
    @course.destroy
    head :no_content
  end

  private

  def set_course
    @course = Course.includes(sections: :units).find(params[:id])
  end

  def course_params
    params.require(:course).permit(:name, :teacher_name, :description)
  end
end
