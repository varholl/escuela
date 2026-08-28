module Admin
  class PagesController < BaseController
    before_action :set_page, only: %i[ edit update ]

    # Every key/locale pair is materialised on first visit so the list is never
    # empty and adding a locale never needs a migration or a seed run.
    def index
      @pages = ensure_all_pages_exist
    end

    def edit
    end

    def update
      purge_feature_video_if_requested

      if @page.update(page_params)
        redirect_to edit_admin_page_path(@page), notice: t("admin.pages.updated")
      else
        render :edit, status: :unprocessable_content
      end
    end

    private
      def set_page
        @page = Page.find(params[:id])
      end

      def page_params
        params.expect(page: [ :title, :subtitle, :body, :cover_image, :feature_video ])
      end

      # Same rule as a lesson video: choosing a replacement in the same submit
      # wins over the remove box, or the purge would delete what was just sent.
      def purge_feature_video_if_requested
        return unless params.dig(:page, :remove_feature_video) == "1"
        return if page_params[:feature_video].present?

        @page.feature_video.purge_later
      end

      def ensure_all_pages_exist
        Page::KEYS.product(I18n.available_locales.map(&:to_s)).each do |key, locale|
          Page.find_or_create_by!(key: key, locale: locale)
        end

        # Rows in a locale that is no longer served stay in the table but out
        # of the panel: she has no way to publish them and no reason to see them.
        Page.where(locale: I18n.available_locales.map(&:to_s)).order(:key, :locale)
      end
  end
end
