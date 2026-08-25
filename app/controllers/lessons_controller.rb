class LessonsController < ApplicationController
  before_action :set_course
  before_action :set_lesson

  def show
    unless @lesson.viewable_by?(current_user)
      # Say plainly that the door is closed rather than pretending nothing is
      # there: the lesson's existence is already public on the course page.
      return redirect_to course_path(id: @course), alert: t("lessons.show.locked")
    end

    set_neighbours
  end

  private
    def set_course
      @course = Course.in_locale(I18n.locale).published.find_by!(slug: params[:course_id])
    end

    def set_lesson
      @lesson = @course.lessons.find_by!(slug: params[:id])
    end

    # Only step between lessons this reader is actually allowed to open, so the
    # arrows never point at a locked door.
    def set_neighbours
      reachable = @course.lessons_visible_to(current_user).select { |l| l.viewable_by?(current_user) }
      position = reachable.index(@lesson)
      return if position.nil?

      @previous = reachable[position - 1] if position.positive?
      @next = reachable[position + 1]
    end
end
