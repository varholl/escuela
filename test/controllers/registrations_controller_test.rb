require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  setup { @course = Course.create!(title: "Atención plena", status: :published) }

  def valid_params(overrides = {})
    { user: {
      name: "Ana", email_address: "ana@example.com",
      password: "una-clave-larga", password_confirmation: "una-clave-larga"
    }.merge(overrides) }
  end

  test "new renders the form" do
    get new_registration_path

    assert_response :success
    assert_select "form[action=?]", registration_path
  end

  test "new mentions the course the visitor came from" do
    get new_registration_path(course: @course.slug)

    assert_select "p", text: I18n.t("registrations.new.for_course", course: @course.title)
  end

  test "signing up creates a student and starts a session" do
    assert_difference -> { User.count }, 1 do
      post registration_path, params: valid_params
    end

    user = User.last
    assert user.student?, "a self-service sign-up must never create an admin"
    assert cookies[:session_id].present?
    assert_redirected_to library_path
  end

  test "signing up from a free course enrolls immediately" do
    assert_difference -> { Enrollment.count }, 1 do
      post registration_path(course: @course.slug), params: valid_params
    end

    assert_redirected_to course_path(id: @course)
    assert @course.reload.enrolled?(User.last)
    assert_equal "self_serve", Enrollment.last.source
  end

  test "signing up from a paid course does not enroll" do
    @course.update!(price_cents: 10_000_00)

    assert_no_difference -> { Enrollment.count } do
      post registration_path(course: @course.slug), params: valid_params
    end

    assert_redirected_to course_path(id: @course)
  end

  test "a short password is refused" do
    assert_no_difference -> { User.count } do
      post registration_path, params: valid_params(password: "corta", password_confirmation: "corta")
    end

    assert_response :unprocessable_content
  end

  test "an email already in use is refused" do
    assert_no_difference -> { User.count } do
      post registration_path, params: valid_params(email_address: users(:student).email_address)
    end

    assert_response :unprocessable_content
  end

  test "the role cannot be forced through the form" do
    post registration_path, params: valid_params.deep_merge(user: { role: "admin" })

    assert User.last.student?
  end
end
