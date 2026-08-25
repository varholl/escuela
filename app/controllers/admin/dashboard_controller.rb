module Admin
  class DashboardController < BaseController
    def show
      @articles = Article.recent_first.limit(5)
      @courses = Course.ordered.limit(5)
      @inquiries = Inquiry.unhandled.recent_first.limit(5)

      @counts = {
        articles: Article.count,
        published_articles: Article.published.count,
        courses: Course.count,
        published_courses: Course.published.count,
        unhandled_inquiries: Inquiry.unhandled.count
      }
    end
  end
end
