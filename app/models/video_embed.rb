# Turns whatever she pasted -- a watch URL, a share link, an embed snippet, or a
# bare id -- into the one player address we are willing to put in an iframe.
#
# Only the video's id is ever taken from her input. The address around it is
# always built here, so nothing she pastes can choose where a frame points.
module VideoEmbed
  YOUTUBE_ID = %r{(?:youtu\.be/|v=|embed/|shorts/)([A-Za-z0-9_-]{6,})}
  VIMEO_ID = %r{vimeo\.com/(?:video/)?(\d+)}
  BARE_ID = /\A[A-Za-z0-9_-]+\z/

  # Free text has to name the site, or any link with a "v=" in it would do.
  YOUTUBE_URL = %r{\Ahttps?://(?:www\.|m\.)?(?:youtube\.com|youtube-nocookie\.com|youtu\.be)/\S+\z}
  VIMEO_URL = %r{\Ahttps?://(?:www\.|player\.)?vimeo\.com/\S+\z}
  IFRAME = %r{\A<iframe\b[^>]*\bsrc=["']([^"']+)["'][^>]*>\s*</iframe>\z}im

  module_function

  # A lesson already says which provider it uses, so a bare id is enough.
  def for_provider(provider, reference)
    reference = reference.to_s.strip
    return nil if reference.blank?

    case provider
    when "youtube" then youtube(reference[YOUTUBE_ID, 1] || (reference if reference.match?(BARE_ID)))
    when "vimeo"   then vimeo(reference[VIMEO_ID, 1] || (reference if reference.match?(/\A\d+\z/)))
    end
  end

  # A line of rich text says nothing about provider, so it has to be a whole
  # YouTube or Vimeo link, or the <iframe> snippet those sites hand out.
  def from_text(text)
    text = text.to_s.strip
    text = text[IFRAME, 1].to_s.strip if text.match?(IFRAME)

    if text.match?(YOUTUBE_URL)
      youtube(text[YOUTUBE_ID, 1])
    elsif text.match?(VIMEO_URL)
      vimeo(text[VIMEO_ID, 1])
    end
  end

  # nocookie keeps YouTube from setting tracking cookies on her students.
  def youtube(id)
    id && "https://www.youtube-nocookie.com/embed/#{id}?rel=0"
  end

  def vimeo(id)
    id && "https://player.vimeo.com/video/#{id}"
  end
end
