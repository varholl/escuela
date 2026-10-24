require "test_helper"

module Admin
  class UsersControllerTest < ActionDispatch::IntegrationTest
    setup do
      sign_in_as users(:owner)
      @student = users(:student)
    end

    test "lists everyone with an account" do
      get admin_users_path

      assert_response :success
      assert_select "a[href=?]", admin_user_path(@student), text: @student.display_name
      assert_select "a[href=?]", admin_user_path(users(:owner))
    end

    test "searches by name or email" do
      get admin_users_path(q: "alumna@")

      assert_select "a[href=?]", admin_user_path(@student)
      assert_select "a[href=?]", admin_user_path(users(:owner)), count: 0
    end

    test "filters the deactivated" do
      @student.deactivate!

      get admin_users_path(filter: "deactivated")

      assert_select "a[href=?]", admin_user_path(@student)
      assert_select "a[href=?]", admin_user_path(users(:owner)), count: 0

      get admin_users_path(filter: "students")

      assert_select "a[href=?]", admin_user_path(@student), count: 0
    end

    test "a person's page shows their courses and what they wrote" do
      course = Course.create!(title: "Atención plena", status: :published)
      course.join!(@student)
      Inquiry.create!(name: "Alumna", email: @student.email_address, message: "¿Cuándo empieza el próximo grupo?")

      get admin_user_path(@student)

      assert_response :success
      assert_select "a[href=?]", edit_admin_course_path(course), text: course.title
      assert_select "a", text: /próximo grupo/
    end

    test "deactivating and reactivating" do
      post admin_user_deactivation_path(@student)

      assert_redirected_to admin_user_path(@student)
      assert @student.reload.deactivated?

      delete admin_user_deactivation_path(@student)

      assert_not @student.reload.deactivated?
    end

    test "an administrator is offered no deactivation, and a forced one is refused" do
      owner = users(:owner)

      get admin_user_path(owner)
      assert_select "form[action=?]", admin_user_deactivation_path(owner), count: 0

      post admin_user_deactivation_path(owner)

      assert_not owner.reload.deactivated?
      assert_equal "Una cuenta de administradora no se puede desactivar.", flash[:alert]
    end

    test "enrolling someone from their own page" do
      course = Course.create!(title: "Atención plena", status: :published)

      assert_difference -> { course.enrollments.count }, 1 do
        post admin_user_enrollments_path(@student), params: { course_id: course.id }
      end

      assert_redirected_to admin_user_path(@student)
      assert course.enrolled?(@student)
    end

    test "the course list on a person's page leaves out what they already have" do
      joined = Course.create!(title: "Ya inscripta", status: :published)
      joined.join!(@student)
      other = Course.create!(title: "Otro curso", status: :published)

      get admin_user_path(@student)

      assert_select "select[name=course_id] option[value=?]", other.id.to_s
      assert_select "select[name=course_id] option[value=?]", joined.id.to_s, count: 0
    end

    test "a student cannot open the list" do
      sign_out
      sign_in_as @student

      get admin_users_path

      assert_redirected_to library_path
    end
  end
end
