module Admin
  class BaseController < ApplicationController
    layout "admin"

    # ApplicationController opens the whole app up; the back office opts back in.
    before_action :require_authentication
    before_action :require_admin

    private
      def require_admin
        redirect_to root_path, alert: t("admin.access_denied") unless Current.user&.admin?
      end
  end
end
