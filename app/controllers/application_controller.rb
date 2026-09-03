class ApplicationController < ActionController::Base
  include Authentication
  # Included after Authentication on purpose: the gate asks whether there is a
  # session before deciding to turn anyone away.
  include Gate

  # The site is public by default; Admin::BaseController opts back in to
  # authentication. Keeping the concern included here means views everywhere can
  # still ask `authenticated?` to decide whether to show the admin shortcut.
  allow_unauthenticated_access

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :redirect_to_canonical_host
  around_action :switch_locale

  helper_method :current_user, :admin?

  # Spanish, the default locale, is served without a prefix; every other locale
  # keeps its `/:locale` segment on generated links.
  def default_url_options
    I18n.locale == I18n.default_locale ? {} : { locale: I18n.locale }
  end

  private
    # Rails' health check controller does not inherit from here, so /up is never
    # redirected and Fly's checks keep working.
    def redirect_to_canonical_host
      canonical = Rails.configuration.x.canonical_host
      return if canonical.blank? || request.host == canonical

      # fullpath keeps the path and the query string exactly as they were.
      redirect_to "https://#{canonical}#{request.fullpath}",
        status: :moved_permanently, allow_other_host: true
    end

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
