module Admin
  class ArticlesController < BaseController
    before_action :set_article, only: %i[ show edit update destroy ]

    def index
      @articles = Article.recent_first
    end

    def show
      redirect_to edit_admin_article_path(@article)
    end

    def new
      @article = Article.new(locale: I18n.locale)
    end

    def edit
    end

    def create
      @article = Article.new(article_params)

      if @article.save
        redirect_to edit_admin_article_path(@article), notice: t("admin.articles.created")
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @article.update(article_params)
        redirect_to edit_admin_article_path(@article), notice: t("admin.articles.updated")
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @article.destroy!
      redirect_to admin_articles_path, notice: t("admin.articles.destroyed"), status: :see_other
    end

    private
      def set_article
        @article = Article.find_by!(slug: params[:id])
      end

      def article_params
        params.expect(article: [ :title, :slug, :excerpt, :locale, :body, :cover_image, :published_at ])
      end
  end
end
