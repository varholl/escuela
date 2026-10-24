module Admin
  module Users
    # Giving someone a course from their own page, for when she starts from the
    # person rather than the course. The same grant as the course's own form.
    class EnrollmentsController < BaseController
      def create
        user = User.find(params[:user_id])
        course = Course.where.not(status: :archived).find(params[:course_id])
        enrollment = course.enrollments.build(user: user, status: :active, source: "manual", granted_at: Time.current)

        if enrollment.save
          StudentMailer.enrolled(enrollment).deliver_later if ApplicationMailer.enabled?
          redirect_to admin_user_path(user), notice: t("admin.users.enrolled", course: course.title), status: :see_other
        else
          redirect_to admin_user_path(user), alert: enrollment.errors.full_messages.to_sentence, status: :see_other
        end
      end
    end
  end
end
