module ArticlesHelper
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
