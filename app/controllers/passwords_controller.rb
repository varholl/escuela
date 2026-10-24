class PasswordsController < ApplicationController
  layout "auth"

  # Someone who cannot get in is exactly who needs this.
  allow_gated_access

  before_action :require_email_delivery
  before_action :set_user_by_token, only: %i[ edit update ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_password_path, alert: t("sessions.throttled") }

  def new
  end

  def create
    # The same answer either way, so the form cannot be used to learn which
    # addresses have accounts, or which of them are shut.
    if user = User.active.find_by(email_address: params[:email_address])
      PasswordsMailer.reset(user).deliver_later
    end

    redirect_to new_session_path, notice: t("passwords.reset_sent")
  end

  def edit
  end

  def update
    if @user.update(params.permit(:password, :password_confirmation))
      @user.sessions.destroy_all
      redirect_to new_session_path, notice: t("passwords.updated")
    else
      redirect_to edit_password_path(params[:token]), alert: t("passwords.mismatch")
    end
  end

  private
    def require_email_delivery
      return if ApplicationMailer.enabled?

      redirect_to new_session_path, alert: t("passwords.unavailable")
    end

    def set_user_by_token
      @user = User.find_by_password_reset_token!(params[:token])
      # A link sent before the account was shut must not open it again.
      raise ActiveSupport::MessageVerifier::InvalidSignature if @user.deactivated?
    rescue ActiveSupport::MessageVerifier::InvalidSignature
      redirect_to new_password_path, alert: t("passwords.invalid_token")
    end
end
