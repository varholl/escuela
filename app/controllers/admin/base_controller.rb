module Admin
  class BaseController < ApplicationController
    layout "admin"

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
