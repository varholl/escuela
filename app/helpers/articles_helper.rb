module ArticlesHelper
  # Each section has its own routes, so a piece's address depends on which one
  # it belongs to. Always link through these rather than the route helpers.
  def article_path_for(article)
    article.note? ? note_path(id: article) : reflection_path(id: article)
  end

  def article_url_for(article)
    article.note? ? note_url(id: article) : reflection_url(id: article)
  end

  def article_cover_url_for(article)
    article.note? ? cover_note_url(id: article) : cover_reflection_url(id: article)
  end

  def articles_path_for(kind)
    kind.to_s == "note" ? notes_path : reflections_path
  end

  def article_reading_time(article)
    t("articles.reading_time", count: article.reading_time_minutes)
  end

  def article_meta(article)
    [ localized_date(article.published_at), article_reading_time(article) ].compact_blank
  end

  # wa.me is WhatsApp's own hand-off: on a phone it opens the app, on a desktop
  # it opens web.whatsapp.com. Without a number it asks who to send it to,
  # which is the whole point -- she is not the recipient, a friend is.
  def whatsapp_share_url(title, url)
    "https://wa.me/?text=#{ERB::Util.url_encode("#{title} #{url}")}"
  end
end
