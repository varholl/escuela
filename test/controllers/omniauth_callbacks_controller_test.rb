require "test_helper"

class OmniauthCallbacksControllerTest < ActionDispatch::IntegrationTest
  setup do
    OmniAuth.config.test_mode = true
    Rails.application.env_config["omniauth.auth"] = google_auth
  end

  teardown do
    OmniAuth.config.test_mode = false
    Rails.application.env_config.delete("omniauth.auth")
    Rails.application.env_config.delete("omniauth.params")
  end

  def google_auth(email: "nueva@example.com", verified: true, uid: "google-123")
    OmniAuth::AuthHash.new(
      provider: "google_oauth2", uid: uid,
      info: { email: email, email_verified: verified, name: "Ana Google" }
    )
  end

  def arriving_from(course)
    Rails.application.env_config["omniauth.params"] = { "course" => course.slug }
  end

  test "a new visitor is signed in and lands on her shelf" do
    assert_difference -> { User.count }, 1 do
      get google_callback_path
    end

    assert_redirected_to library_path
    assert cookies[:session_id].present?
  end

  test "an administrator lands in the panel" do
    Rails.application.env_config["omniauth.auth"] = google_auth(email: users(:owner).email_address)

    get google_callback_path

    assert_redirected_to admin_root_path
  end

  test "arriving from a free course joins it and lands inside" do
    course = Course.create!(title: "Atención plena", status: :published)
    arriving_from course

    assert_difference -> { Enrollment.count }, 1 do
      get google_callback_path
    end

    assert_redirected_to course_path(id: course)
  end

  test "arriving from a paid course signs in but does not enroll" do
    course = Course.create!(title: "Atención plena", status: :published, price_cents: 10_000_00)
    arriving_from course

    assert_no_difference -> { Enrollment.count } do
      get google_callback_path
    end

    assert_redirected_to course_path(id: course)
  end

  test "an unverified address is turned away without creating anything" do
    Rails.application.env_config["omniauth.auth"] = google_auth(verified: false)

    assert_no_difference -> { User.count } do
      get google_callback_path
    end

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id].presence
  end

  test "a failure from Google says so instead of showing a stack trace" do
    get "/auth/failure"

    assert_redirected_to new_session_path
    follow_redirect!
    assert_select "div", text: /#{I18n.t("sessions.google_failed")}/
  end

  test "the callback does not require one of our CSRF tokens" do
    # It is a GET from Google, which carries no token of ours.
    get google_callback_path

    assert_response :redirect
  end
end
