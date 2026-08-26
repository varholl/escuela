class PagesController < ApplicationController
  def home
    @courses = published_courses.ordered.limit(3)
    @articles = published_articles.recent_first.limit(3)
    @portrait = Page.for(:about)&.cover_image
    @feature = Page.for(:home)
  end

  def about
    @page = Page.for(:about)
  end

  def philosophy
    @page = Page.for(:philosophy)
  end

  private
    def published_courses
      Course.in_locale(I18n.locale).published
    end

    def published_articles
      Article.in_locale(I18n.locale).published
    end
end
