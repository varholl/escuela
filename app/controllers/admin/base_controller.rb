module Admin
  class BaseController < ApplicationController
    layout "admin"

    # She has to be able to reach the panel from a signed-out browser, and the
    # sign-in redirect below is what gets her there; the gate would send her to
    # the holding page instead. Nothing leaks, because the panel is the one
    # place that was never public.
    allow_gated_access

    # ApplicationController opens the whole app up; the back office opts back in.
    before_action :require_authentication
    before_action :require_admin

    private
      def require_admin
        return if Current.user&.admin?

        redirect_to library_path, alert: t("admin.access_denied")
      end
  end
end
