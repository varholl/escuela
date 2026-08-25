module Admin
  # Lets the owner change her own name, email and password without a console.
  class AccountsController < BaseController
    before_action :set_user

    def edit
    end

    def update
      @user.current_password = account_params[:current_password]

      unless @user.authenticate(@user.current_password.to_s)
        @user.errors.add(:current_password, :invalid)
        return render :edit, status: :unprocessable_content
      end

      if @user.update(changes)
        sign_out_other_devices if password_changed?
        redirect_to edit_admin_account_path, notice: t("admin.account.updated")
      else
        render :edit, status: :unprocessable_content
      end
    end

    private
      def set_user
        @user = Current.user
      end

      def account_params
        params.expect(user: [ :name, :email_address, :current_password, :password, :password_confirmation ])
      end

      # A blank password field means "leave the password alone" rather than
      # "set an empty password".
      def changes
        attributes = account_params.except(:current_password)
        password_changed? ? attributes : attributes.except(:password, :password_confirmation)
      end

      def password_changed?
        account_params[:password].present?
      end

      # A new password should not leave old sessions elsewhere still signed in.
      def sign_out_other_devices
        @user.sessions.where.not(id: Current.session.id).destroy_all
      end
  end
end
