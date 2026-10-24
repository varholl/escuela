# Reflections and notes alike; the route says which section this is.
class ArticlesController < ApplicationController
  def index
    @kind = section
    @articles = visible_articles.where(kind: @kind).recent_first
  end

  def show
    @article = visible_articles.find_by!(slug: params[:id])

    # A piece lives in one section only; asked for under the other, it is sent
    # to its own address rather than shown twice.
    return redirect_to helpers.article_path_for(@article), status: :moved_permanently unless @article.kind == section

    @related = visible_articles.where(kind: @article.kind).recent_first.where.not(id: @article.id).limit(2)
    remember_reading
  end

  private
    # Only for someone who asked for it, and only for what is really out: an
    # administrator proofing a draft is not a reader.
    def remember_reading
      return unless current_user&.remembers_reading? && @article.published?

      Reading.record(current_user, @article)
    end

    def section
      Article.kinds.key?(params[:kind]) ? params[:kind] : "reflection"
    end

    # Signed-in admins can follow a link to an unpublished piece to proof it
    # before it goes live; everyone else only ever sees published ones.
    def visible_articles
      scope = Article.in_locale(I18n.locale).with_rich_text_body_and_embeds
      admin? ? scope : scope.published
    end
end
