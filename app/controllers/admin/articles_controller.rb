module Admin
  class ArticlesController < BaseController
    before_action :set_article, only: %i[ show edit update destroy ]

    def index
      @kind = section
      @articles = Article.where(kind: @kind).recent_first
    end

    def show
      redirect_to edit_admin_article_path(@article)
    end

    def new
      @article = Article.new(locale: I18n.locale, kind: section)
    end

    def edit
    end

    def create
      @article = Article.new(article_params.merge(kind: section_param))

      if @article.save
        redirect_to edit_admin_article_path(@article), notice: t("admin.articles.sections.#{@article.kind}.created")
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @article.update(article_params)
        redirect_to edit_admin_article_path(@article), notice: t("admin.articles.sections.#{@article.kind}.updated")
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @article.destroy!
      redirect_to admin_articles_path(kind: @article.kind),
        notice: t("admin.articles.sections.#{@article.kind}.destroyed"), status: :see_other
    end

    private
      # Reflections and notes are listed apart, as the two sections they are on
      # the site; ?kind= says which one.
      def section
        Article.kinds.key?(params[:kind]) ? params[:kind] : "reflection"
      end

      # Only ever read when a piece is created; after that it cannot change.
      def section_param
        kind = params.dig(:article, :kind)
        Article.kinds.key?(kind) ? kind : "reflection"
      end

      def set_article
        @article = Article.find_by!(slug: params[:id])
      end

      def article_params
        params.expect(article: [ :title, :excerpt, :locale, :body, :cover_image, :published_at, :tag_list ])
      end
  end
end
