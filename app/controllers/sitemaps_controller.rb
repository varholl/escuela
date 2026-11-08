# The list of public addresses handed to search engines, so a new note or course
# is found without waiting for a crawler to stumble on a link to it. It follows
# the same switches as robots.txt: while the site is closed there is nothing to
# list, and the address answers 404.
class SitemapsController < ApplicationController
  allow_gated_access

  def show
    return head :not_found unless RobotsController.indexable?

    @articles = Article.in_locale(I18n.locale).published.recent_first
    @courses = Course.in_locale(I18n.locale).published.ordered
    @pages = Page.in_locale(I18n.locale).index_by(&:key)

    expires_in 1.hour, public: true
  end
end
