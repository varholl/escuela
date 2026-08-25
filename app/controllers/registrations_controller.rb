# Students sign themselves up and choose their own password. That is what lets
# a free course work end to end while there is still no way to send mail.
class RegistrationsController < ApplicationController
  layout "auth"

  rate_limit to: 10, within: 10.minutes, only: :create,
    with: -> { redirect_to new_registration_path, alert: t("registrations.throttled") }

  def new
    @user = User.new
    @requested_course = requested_course
  end

  def create
    @user = User.new(registration_params.merge(role: :student))

    if @user.save
      start_new_session_for @user
      join_requested_course
      redirect_to destination, notice: t("registrations.create.success", name: @user.display_name)
    else
      render :new, status: :unprocessable_content
    end
  end

  private
    def registration_params
      params.expect(user: [ :name, :email_address, :password, :password_confirmation ])
    end

    # Someone who arrived from a course page should land inside it, already
    # enrolled, rather than on an empty library wondering what happened.
    def requested_course
      @requested_course ||= Course.in_locale(I18n.locale).published.find_by(slug: params[:course])
    end

    def join_requested_course
      requested_course&.join!(@user) if requested_course&.joinable_by?(@user)
    end

    def destination
      requested_course ? course_path(id: requested_course) : library_path
    end
end
