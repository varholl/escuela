module Admin
  class EnrollmentsController < BaseController
    before_action :set_course

    def index
      @enrollments = @course.enrollments.includes(:user).order(created_at: :desc)
    end

    def new
      @enrollment = @course.enrollments.build
    end

    # Granting access by email is the phase-one stand-in for a checkout: it
    # creates the student account if it does not exist yet, so she can already
    # sell a course by hand and hand over the login.
    def create
      @enrollment = @course.enrollments.build(
        user: find_or_invite_student,
        status: :active,
        source: "manual",
        granted_at: Time.current
      )

      if @enrollment.user&.persisted? && @enrollment.save
        redirect_to admin_course_enrollments_path(@course), notice: t("admin.enrollments.created")
      else
        render :new, status: :unprocessable_content
      end
    end

    def destroy
      @course.enrollments.find(params[:id]).destroy!
      redirect_to admin_course_enrollments_path(@course),
        notice: t("admin.enrollments.destroyed"), status: :see_other
    end

    private
      def set_course
        @course = Course.find_by!(slug: params[:course_id])
      end

      def find_or_invite_student
        email = params.dig(:enrollment, :email_address).to_s.strip.downcase
        return nil if email.blank?

        User.find_by(email_address: email) || User.create(
          email_address: email,
          name: params.dig(:enrollment, :name),
          password: SecureRandom.base58(24)
        )
      end
  end
end
