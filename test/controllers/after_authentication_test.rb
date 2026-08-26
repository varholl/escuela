require "test_helper"

# Where someone lands right after signing in. Getting this wrong greets a new
# student with "you do not have permission" as her first impression.
class AfterAuthenticationTest < ActionDispatch::IntegrationTest
  def sign_in_with_password(user)
    post session_path, params: { email_address: user.email_address, password: "password" }
  end

  def sign_in_with_google(user)
    OmniAuth.config.test_mode = true
    Rails.application.env_config["omniauth.auth"] = OmniAuth::AuthHash.new(
      provider: "google_oauth2", uid: "google-#{user.id}",
      info: { email: user.email_address, email_verified: true, name: user.name }
    )
    get google_callback_path
  ensure
    OmniAuth.config.test_mode = false
    Rails.application.env_config.delete("omniauth.auth")
  end

  test "a student who tried the admin panel is not sent back into it" do
    get admin_articles_path
    assert_redirected_to new_session_path

    sign_in_with_password users(:student)

    assert_redirected_to library_url, "sending her back to /admin only denies her on arrival"
  end

  test "the same, signing in with Google" do
    get admin_articles_path

    sign_in_with_google users(:student)

    assert_redirected_to library_url
  end

  test "an administrator is still returned to where she was going" do
    get admin_articles_path

    sign_in_with_password users(:owner)

    assert_redirected_to admin_articles_url
  end

  test "a student with nothing pending lands on her shelf" do
    sign_in_with_password users(:student)

    assert_redirected_to library_url
  end

  test "an administrator with nothing pending lands in the panel" do
    sign_in_with_password users(:owner)

    assert_redirected_to admin_root_url
  end

  test "a student is returned to an ordinary page she asked for" do
    get library_path
    assert_redirected_to new_session_path

    sign_in_with_password users(:student)

    assert_redirected_to library_url
  end

  test "a student who reaches the panel anyway is offered her courses" do
    sign_in_as users(:student)

    get admin_root_path

    assert_redirected_to library_path
    follow_redirect!
    assert_select "div", text: /#{I18n.t("admin.access_denied")}/
  end

  test "arriving from a free course still wins over anything pending" do
    course = Course.create!(title: "Atención plena", status: :published)
    get admin_articles_path

    OmniAuth.config.test_mode = true
    Rails.application.env_config["omniauth.auth"] = OmniAuth::AuthHash.new(
      provider: "google_oauth2", uid: "g-1",
      info: { email: "nueva@example.com", email_verified: true, name: "Ana" }
    )
    Rails.application.env_config["omniauth.params"] = { "course" => course.slug }
    get google_callback_path

    assert_redirected_to course_path(id: course)
  ensure
    OmniAuth.config.test_mode = false
    Rails.application.env_config.delete("omniauth.auth")
    Rails.application.env_config.delete("omniauth.params")
  end
end
