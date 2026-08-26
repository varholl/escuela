# An uploaded lesson video, behind the same gate as the lesson page.
#
# Active Storage's own URLs carry a signed id that anyone can pass on, which is
# exactly the sharing this is meant to prevent, so nothing ever links to them
# directly. Access is decided here, and only then are the bytes handed over.
#
# Two ways to hand them over, because they trade off differently:
#
#   redirect (default)  A signed URL straight to the storage service. The bytes
#                       never touch this machine, so it costs nothing to serve
#                       -- egress from R2 is free, while egress from Fly in
#                       Sao Paulo is $0.04/GB. The link works until it expires.
#
#   proxy               Everything is streamed through here, so no usable URL
#                       ever leaves the server. Strictest, but every megabyte
#                       watched is billed as Fly bandwidth and occupies the
#                       machine. Set VIDEO_DELIVERY=proxy to choose it.
class LessonVideosController < ApplicationController
  include ActiveStorage::Streaming
  # Disk-service URLs need to know the host they are being generated for.
  include ActiveStorage::SetCurrent

  # A signed link has to outlive the viewing session: seeking re-requests the
  # same URL, so an expiry shorter than the lesson breaks playback.
  LINK_LIFETIME = Integer(ENV.fetch("VIDEO_LINK_MINUTES", 120)).minutes

  before_action :set_lesson

  def show
    return head :not_found unless @lesson.video.attached?
    return head :forbidden unless @lesson.viewable_by?(current_user)

    if proxied?
      send_blob_stream @lesson.video.blob, disposition: "inline"
    else
      redirect_to @lesson.video.url(expires_in: LINK_LIFETIME), allow_other_host: true
    end
  end

  private
    def proxied?
      ENV["VIDEO_DELIVERY"] == "proxy"
    end

    def set_lesson
      course = Course.in_locale(I18n.locale).published.find_by!(slug: params[:course_id])
      @lesson = course.lessons.find_by!(slug: params[:id])
    end
end
