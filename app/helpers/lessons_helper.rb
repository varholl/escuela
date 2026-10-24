module LessonsHelper
  # She will paste whatever the provider showed her -- a full watch URL, a share
  # link, or the bare id -- so all three have to work.
  def lesson_embed_url(lesson)
    VideoEmbed.for_provider(lesson.video_provider, lesson.video_reference)
  end

  # The stored values name backends; these name them the way she thinks about
  # them, and are used in the form as well as the lesson list.
  def lesson_provider_label(provider)
    return nil if provider.blank?

    t("admin.lessons.providers.#{provider}", default: provider)
  end

  def lesson_provider_options
    Lesson::VIDEO_PROVIDERS.map { |provider| [ lesson_provider_label(provider), provider ] }
  end

  def lesson_has_player?(lesson)
    lesson.video_provider == "active_storage" ? lesson.video.attached? : lesson_embed_url(lesson).present?
  end
end
