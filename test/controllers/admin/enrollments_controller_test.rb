require "test_helper"

module Admin
  class EnrollmentsControllerTest < ActionDispatch::IntegrationTest
    setup do
      sign_in_as users(:owner)
      @course = Course.create!(title: "Fundamentos de atención plena", status: :published)
    end

    test "granting access to an existing student" do
      student = users(:student)

      assert_difference -> { Enrollment.count }, 1 do
        post admin_course_enrollments_path(@course),
          params: { enrollment: { email_address: student.email_address } }
      end

      enrollment = Enrollment.last
      assert_equal student, enrollment.user
      assert enrollment.grants_access?
      assert_equal "manual", enrollment.source
    end

    test "granting access to a new email creates the account" do
      assert_difference -> { User.count }, 1 do
        post admin_course_enrollments_path(@course),
          params: { enrollment: { email_address: "Nueva@Example.com", name: "Nueva" } }
      end

      assert_equal "nueva@example.com", User.last.email_address
      assert User.last.student?
    end

    test "a blank email re-renders the form" do
      assert_no_difference -> { Enrollment.count } do
        post admin_course_enrollments_path(@course), params: { enrollment: { email_address: "" } }
      end

      assert_response :unprocessable_content
    end

    test "revoking access" do
      enrollment = @course.enrollments.create!(user: users(:student), status: :active)

      assert_difference -> { Enrollment.count }, -1 do
        delete admin_course_enrollment_path(@course, enrollment)
      end
    end
  end
end
