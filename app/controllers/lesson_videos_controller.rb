# A lesson video, behind the same gate as the lesson page.
class LessonVideosController < ApplicationController
  include VideoDelivery

  before_action :set_lesson

  def show
    return head :not_found unless @lesson.video.attached?
    return head :forbidden unless @lesson.viewable_by?(current_user)

    deliver_video @lesson.video
  end

  private
    def set_lesson
      course = Course.in_locale(I18n.locale).published.find_by!(slug: params[:course_id])
      @lesson = course.lessons.find_by!(slug: params[:id])
    end
end
