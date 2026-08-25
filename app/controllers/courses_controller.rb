class CoursesController < ApplicationController
  def index
    @courses = visible_courses.ordered
  end

  def show
    @course = visible_courses.find_by!(slug: params[:id])
    @lessons = @course.lessons_visible_to(current_user)
  end

  private
    def visible_courses
      scope = Course.in_locale(I18n.locale)
      admin? ? scope.where.not(status: :archived) : scope.published
    end
end
