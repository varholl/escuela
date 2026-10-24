class CoursesController < ApplicationController
  # How many of each the overview shows before offering the full list.
  PREVIEW = 3

  # The overview shows the newest few courses and workshops, each with a way to
  # the whole list; ?ver=cursos or ?ver=talleres is that list, in her order. A
  # query string rather than a path of its own, so no course slug can ever
  # collide with it.
  def index
    @showing = params[:ver].presence_in(%w[ cursos talleres ])
    courses = visible_courses.course
    workshops = visible_courses.workshop

    case @showing
    when "cursos"
      @courses, @workshops = courses.ordered, Course.none
    when "talleres"
      @courses, @workshops = Course.none, workshops.ordered
    else
      @courses = courses.order(created_at: :desc).limit(PREVIEW)
      @workshops = workshops.order(created_at: :desc).limit(PREVIEW)
      @more_courses = courses.count > PREVIEW
      @more_workshops = workshops.count > PREVIEW
    end
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
