require "test_helper"

# The button only exists where Google is actually configured, so development and
# a fresh clone do not show a door that leads nowhere.
class GoogleButtonTest < ActionDispatch::IntegrationTest
  setup { @original = Rails.configuration.x.google_sign_in }
  teardown { Rails.configuration.x.google_sign_in = @original }

  test "the default is a real false, not an empty OrderedOptions" do
    # An unset config.x key is truthy, which would put a dead button on the
    # page of every install that has not configured Google.
    assert_equal false, Rails.configuration.x.google_sign_in
  end

  test "no button when Google is not configured" do
    get new_session_path

    assert_select "form[action*=?]", "google_oauth2", count: 0
  end

  test "the sign-in screen offers it once configured" do
    Rails.configuration.x.google_sign_in = true

    get new_session_path

    assert_select "form[action=?]", "/auth/google_oauth2"
  end

  test "the request phase is a POST, never a GET" do
    Rails.configuration.x.google_sign_in = true

    get new_session_path

    # A GET request phase is the login-CSRF hole omniauth-rails_csrf_protection
    # exists to close.
    assert_select "form[action=?][method=?]", "/auth/google_oauth2", "post"
    assert_select "a[href*=?]", "auth/google_oauth2", count: 0
  end

  test "signing up from a course carries the course through Google" do
    Rails.configuration.x.google_sign_in = true
    course = Course.create!(title: "Atención plena", status: :published)

    get new_registration_path(course: course.slug)

    assert_select "form[action=?]", "/auth/google_oauth2?course=#{course.slug}"
  end
end
