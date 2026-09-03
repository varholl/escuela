# Joining a free course. Paid courses still go through the contact form until
# there is a way to take money; `joinable_by?` is what keeps that honest.
class EnrollmentsController < ApplicationController
  # Authentication already answers this one, and its redirect is the useful one.
  allow_gated_access
  before_action :require_authentication
  before_action :set_course

  def create
    if @course.enrolled?(Current.user)
      redirect_to course_path(id: @course), notice: t("enrollments.create.already")
    elsif @course.joinable_by?(Current.user)
      @course.join!(Current.user)
      redirect_to course_path(id: @course), notice: t("enrollments.create.success")
    else
      redirect_to course_path(id: @course), alert: t("enrollments.create.unavailable")
    end
  end

  private
    def set_course
      @course = Course.in_locale(I18n.locale).published.find_by!(slug: params[:course_id])
    end
end
