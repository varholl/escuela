require "test_helper"

# Turning someone away has to shut every way in, not just the sign-in form.
class DeactivatedAccountsTest < ActionDispatch::IntegrationTest
  setup do
    @student = users(:student)
  end

  test "deactivating keeps the record and closes the sessions" do
    @student.sessions.create!

    @student.deactivate!

    assert @student.reload.deactivated?
    assert_empty @student.sessions
  end

  test "an administrator cannot be deactivated" do
    assert_raises(ArgumentError) { users(:owner).deactivate! }
    assert_not users(:owner).deactivatable?
  end

  test "reactivating opens the door again" do
    @student.deactivate!
    @student.reactivate!

    assert_not @student.reload.deactivated?
  end

  test "signing in records when they came, and it outlives signing out" do
    post session_path, params: { email_address: @student.email_address, password: "password" }
    delete session_path

    assert_in_delta Time.current, @student.reload.last_signed_in_at, 5.seconds
    assert_empty @student.sessions
  end

  test "the right password no longer signs them in" do
    @student.deactivate!

    post session_path, params: { email_address: @student.email_address, password: "password" }

    assert_redirected_to new_session_path
    assert_equal "Tu cuenta está desactivada. Si creés que es un error, escribime.", flash[:alert]
    assert_empty @student.sessions.reload
  end

  test "a session already open stops working" do
    sign_in_as @student
    # Deleting the sessions is the first line; this checks the second, in case
    # one ever survived it.
    @student.update_column(:deactivated_at, Time.current)

    get library_path

    assert_redirected_to new_session_path
  end

  test "google no longer signs them in" do
    OmniAuth.config.test_mode = true
    Rails.application.env_config["omniauth.auth"] = OmniAuth::AuthHash.new(
      provider: "google_oauth2", uid: "google-123",
      info: { email: @student.email_address, email_verified: true, name: "Alumna" }
    )
    @student.deactivate!

    get google_callback_path

    assert_redirected_to new_session_path
    assert_equal "Tu cuenta está desactivada. Si creés que es un error, escribime.", flash[:alert]
    assert_empty @student.sessions.reload
  ensure
    OmniAuth.config.test_mode = false
    Rails.application.env_config.delete("omniauth.auth")
  end

  test "no reset link is sent, and the answer is the same as for anyone" do
    @student.deactivate!

    post passwords_path, params: { email_address: @student.email_address }

    assert_enqueued_emails 0
    assert_redirected_to new_session_path
  end

  test "a reset link sent before the account was shut does not open it" do
    token = @student.password_reset_token
    @student.deactivate!

    put password_path(token), params: { password: "una-nueva-clave", password_confirmation: "una-nueva-clave" }

    assert_redirected_to new_password_path
    assert @student.reload.authenticate("password")
  end
end
