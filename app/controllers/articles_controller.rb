class ArticlesController < ApplicationController
  def index
    @articles = visible_articles.recent_first
  end

  def show
    @article = visible_articles.find_by!(slug: params[:id])
    @related = visible_articles.recent_first.where.not(id: @article.id).limit(2)
  end

  private
    # Signed-in admins can follow a link to an unpublished note to proof it
    # before it goes live; everyone else only ever sees published ones.
    def visible_articles
      scope = Article.in_locale(I18n.locale).with_rich_text_body_and_embeds
      admin? ? scope : scope.published
    end
end
