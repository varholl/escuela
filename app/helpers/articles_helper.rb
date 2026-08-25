module ArticlesHelper
  def article_reading_time(article)
    t("articles.reading_time", count: article.reading_time_minutes)
  end

  def article_meta(article)
    [ localized_date(article.published_at), article_reading_time(article) ].compact_blank
  end
end
