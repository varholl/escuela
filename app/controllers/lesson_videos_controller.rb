# An uploaded lesson video, served through the same gate as the lesson page.
#
# Active Storage's own URLs carry a signed id that anyone can pass on, which is
# exactly the sharing this is meant to prevent, so the bytes go out through here
# instead. send_blob_stream honours Range requests, so seeking still works.
class LessonVideosController < ApplicationController
  include ActiveStorage::Streaming

  before_action :set_lesson

  def show
    return head :not_found unless @lesson.video.attached?
    return head :forbidden unless @lesson.viewable_by?(current_user)

    send_blob_stream @lesson.video.blob, disposition: "inline"
  end

  private
    def set_lesson
      course = Course.in_locale(I18n.locale).published.find_by!(slug: params[:course_id])
      @lesson = course.lessons.find_by!(slug: params[:id])
    end
end
