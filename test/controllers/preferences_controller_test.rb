require "test_helper"

class PreferencesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @student = users(:student)
  end

  test "asks for an account" do
    get edit_preferences_path

    assert_redirected_to new_session_path
  end

  test "both permissions start off" do
    sign_in_as @student

    get edit_preferences_path

    assert_response :success
    assert_select "input[type=checkbox][name=?]:not([checked])", "user[remember_reading]"
    assert_select "input[type=checkbox][name=?]:not([checked])", "user[wants_news]"
  end

  test "giving them records when" do
    sign_in_as @student

    patch preferences_path, params: { user: { remember_reading: "1", wants_news: "1" } }

    assert_redirected_to edit_preferences_path
    @student.reload
    assert @student.remembers_reading?
    assert @student.wants_news?
    assert_in_delta Time.current, @student.news_consent_at, 5.seconds
  end

  test "saving again keeps the date it was first given" do
    given = 3.days.ago.change(usec: 0)
    @student.update!(news_consent_at: given)
    sign_in_as @student

    patch preferences_path, params: { user: { remember_reading: "0", wants_news: "1" } }

    assert_equal given, @student.reload.news_consent_at
  end

  test "only these two can be changed here" do
    sign_in_as @student

    patch preferences_path, params: { user: { wants_news: "1", role: "admin", email_address: "otra@example.com" } }

    assert @student.reload.student?
    assert_equal "alumna@example.com", @student.email_address
  end

  test "her shelf links to them" do
    sign_in_as @student

    get library_path

    assert_select "a[href=?]", edit_preferences_path
  end

  test "signing up offers them, unticked, and honours a tick" do
    get new_registration_path
    assert_select "input[type=checkbox][name=?]:not([checked])", "user[remember_reading]"

    post registration_path, params: { user: {
      name: "Nueva", email_address: "nueva@example.com", password: "una-clave-larga",
      password_confirmation: "una-clave-larga", remember_reading: "0", wants_news: "1"
    } }

    user = User.find_by!(email_address: "nueva@example.com")
    assert user.wants_news?
    assert_not user.remembers_reading?
  end
end
