class ApplicationController < ActionController::Base
  include Authentication

  # The site is public by default; Admin::BaseController opts back in to
  # authentication. Keeping the concern included here means views everywhere can
  # still ask `authenticated?` to decide whether to show the admin shortcut.
  allow_unauthenticated_access

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  around_action :switch_locale

  helper_method :current_user, :admin?

  # Spanish, the default locale, is served without a prefix; every other locale
  # keeps its `/:locale` segment on generated links.
  def default_url_options
    I18n.locale == I18n.default_locale ? {} : { locale: I18n.locale }
  end

  private
    def switch_locale(&action)
      I18n.with_locale(requested_locale, &action)
    end

    def requested_locale
      params[:locale].presence_in(I18n.available_locales.map(&:to_s)) || I18n.default_locale
    end

    def current_user
      Current.user if authenticated?
    end

    def admin?
      current_user&.admin?
    end
end
