class PagesController < ApplicationController
  # The root is the one page that answers with the doors shut, because it is
  # the holding page.
  allow_gated_access only: :home

  def home
    # Her face is the one piece of the site that is already hers, so it is the
    # one piece the holding page keeps.
    @portrait = Page.for(:about)&.cover_image
    return render "pages/gate", layout: "gate" if gated?

    @courses = published_courses.ordered.limit(3)
    @articles = published_articles.recent_first.limit(3)
    @feature = Page.for(:home)
  end

  def about
    @page = Page.for(:about)
  end

  def philosophy
    @page = Page.for(:philosophy)
  end

  def privacy
    @page = Page.for(:privacy)
  end

  def terms
    @page = Page.for(:terms)
  end

  private
    def published_courses
      Course.in_locale(I18n.locale).published
    end

    def published_articles
      Article.in_locale(I18n.locale).published
    end
end
