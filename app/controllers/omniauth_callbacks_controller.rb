# Coming back from Google.
class OmniauthCallbacksController < ApplicationController
  # The way back in has to answer even with the doors shut -- though while they
  # are, only for someone who already has an account here.
  allow_gated_access

  # The request phase is a POST protected by OmniAuth's CSRF middleware; the
  # callback is a GET from Google and carries no CSRF token of ours.
  skip_forgery_protection only: :google_oauth2

  before_action :require_invitation, only: :google_oauth2

  def google_oauth2
    user = User.from_google(request.env["omniauth.auth"])

    if user
      start_new_session_for user
      join_pending_course(user)
      redirect_to destination(user), notice: t("sessions.welcome_back", name: user.display_name)
    else
      # Google says the address is not verified, so it cannot be trusted to
      # identify anyone.
      redirect_to new_session_path, alert: t("sessions.google_unverified")
    end
  end

  def failure
    redirect_to new_session_path, alert: t("sessions.google_failed")
  end

  private
    # A visitor who pressed "join" on a free course before signing in should end
    # up inside it, not on an empty library wondering what happened.
    #
    # The slug rides along in omniauth.params -- the query string of the request
    # phase, handed back to us here -- rather than in the session, which would
    # have to survive a round trip through Google.
    def pending_course
      slug = request.env.dig("omniauth.params", "course")
      return nil if slug.blank?

      Course.in_locale(I18n.locale).published.find_by(slug: slug)
    end

    def join_pending_course(user)
      @pending_course = pending_course
      @pending_course.join!(user) if @pending_course&.joinable_by?(user)
    end

    def destination(user)
      return course_path(id: @pending_course) if @pending_course

      after_authentication_url(user)
    end

    # `gated?` is about the visitor and is always false here -- they are on
    # their way to having a session. What matters is whether the site itself is
    # still closed, because that is what makes the Google button a way back in
    # rather than a way to sign up.
    def require_invitation
      return unless Rails.configuration.x.gated
      return if User.google_account?(request.env["omniauth.auth"])

      redirect_to new_session_path, alert: t("sessions.google_not_invited")
    end
end
