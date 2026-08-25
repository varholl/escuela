module LessonsHelper
  # She will paste whatever the provider showed her -- a full watch URL, a share
  # link, or the bare id -- so all three have to work.
  YOUTUBE_ID = %r{(?:youtu\.be/|v=|embed/|shorts/)([A-Za-z0-9_-]{6,})}
  VIMEO_ID = %r{vimeo\.com/(?:video/)?(\d+)}
  BARE_ID = /\A[A-Za-z0-9_-]+\z/

  def lesson_embed_url(lesson)
    reference = lesson.video_reference.to_s.strip
    return nil if reference.blank?

    case lesson.video_provider
    when "youtube" then youtube_embed(reference)
    when "vimeo"   then vimeo_embed(reference)
    end
  end

  def lesson_has_player?(lesson)
    lesson.video_provider == "active_storage" ? lesson.video.attached? : lesson_embed_url(lesson).present?
  end

  private
    def youtube_embed(reference)
      id = reference[YOUTUBE_ID, 1] || (reference if reference.match?(BARE_ID))
      # nocookie keeps YouTube from setting tracking cookies on her students.
      id && "https://www.youtube-nocookie.com/embed/#{id}?rel=0"
    end

    def vimeo_embed(reference)
      id = reference[VIMEO_ID, 1] || (reference if reference.match?(/\A\d+\z/))
      id && "https://player.vimeo.com/video/#{id}"
    end
end
