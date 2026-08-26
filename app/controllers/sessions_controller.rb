class SessionsController < ApplicationController
  layout "auth"

  # ApplicationController opens the app up, which leaves Current.session unset.
  # Signing out needs it resolved, so this action opts back in.
  before_action :require_authentication, only: :destroy

  rate_limit to: 10, within: 3.minutes, only: :create,
    with: -> { redirect_to new_session_path, alert: t("sessions.throttled") }

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      start_new_session_for user
      redirect_to after_authentication_url
    else
      redirect_to new_session_path, alert: t("sessions.invalid_credentials")
    end
  end

  def destroy
    terminate_session
    redirect_to root_path, status: :see_other, notice: t("sessions.signed_out")
  end
end
