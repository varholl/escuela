module Admin
  module Users
    # Turning someone away, and letting them back in, as a POST/DELETE pair.
    class DeactivationsController < BaseController
      before_action :set_user

      def create
        if @user.deactivatable?
          @user.deactivate!
          redirect_to admin_user_path(@user), notice: t("admin.users.deactivated", name: @user.display_name), status: :see_other
        else
          redirect_to admin_user_path(@user), alert: t("admin.users.cannot_deactivate"), status: :see_other
        end
      end

      def destroy
        @user.reactivate!
        redirect_to admin_user_path(@user), notice: t("admin.users.reactivated", name: @user.display_name), status: :see_other
      end

      private
        def set_user
          @user = User.find(params[:user_id])
        end
    end
  end
end
