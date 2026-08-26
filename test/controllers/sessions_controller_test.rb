require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup { @user = users(:student) }

  test "new" do
    get new_session_path
    assert_response :success
  end

  test "create with valid credentials lands a student on her shelf" do
    post session_path, params: { email_address: @user.email_address, password: "password" }

    assert_redirected_to library_url
    assert cookies[:session_id]
  end

  test "create sends an administrator straight to the panel" do
    post session_path, params: { email_address: users(:owner).email_address, password: "password" }

    assert_redirected_to admin_root_url
  end

  test "create with invalid credentials" do
    post session_path, params: { email_address: @user.email_address, password: "wrong" }

    assert_redirected_to new_session_path
    assert_nil cookies[:session_id]
  end

  test "destroy" do
    sign_in_as @user

    delete session_path

    assert_redirected_to root_path
    assert_empty cookies[:session_id]
  end

  test "destroy without a session asks for one" do
    delete session_path

    assert_redirected_to new_session_path
  end
end
