require "test_helper"

module Admin
  class AccountsControllerTest < ActionDispatch::IntegrationTest
    setup do
      @user = users(:owner)
      sign_in_as @user
    end

    test "edit renders the form" do
      get edit_admin_account_path

      assert_response :success
      assert_select "input[name=?]", "user[current_password]"
    end

    test "updates the name and email with the right current password" do
      patch admin_account_path, params: { user: {
        name: "Flor Di Iorio", email_address: "nuevo@example.com", current_password: "password"
      } }

      assert_redirected_to edit_admin_account_path
      @user.reload
      assert_equal "Flor Di Iorio", @user.name
      assert_equal "nuevo@example.com", @user.email_address
    end

    test "changes the password" do
      assert_changes -> { @user.reload.password_digest } do
        patch admin_account_path, params: { user: {
          current_password: "password", password: "un-secreto-nuevo", password_confirmation: "un-secreto-nuevo"
        } }
      end

      assert_redirected_to edit_admin_account_path
      assert User.authenticate_by(email_address: @user.email_address, password: "un-secreto-nuevo")
    end

    test "a wrong current password changes nothing" do
      assert_no_changes -> { @user.reload.name } do
        patch admin_account_path, params: { user: { name: "Otra", current_password: "incorrecta" } }
      end

      assert_response :unprocessable_content
    end

    test "a blank password field leaves the password alone" do
      assert_no_changes -> { @user.reload.password_digest } do
        patch admin_account_path, params: { user: {
          name: "Solo el nombre", current_password: "password", password: "", password_confirmation: ""
        } }
      end

      assert_equal "Solo el nombre", @user.reload.name
    end

    test "mismatched passwords are rejected" do
      assert_no_changes -> { @user.reload.password_digest } do
        patch admin_account_path, params: { user: {
          current_password: "password", password: "una-cosa", password_confirmation: "otra-cosa"
        } }
      end

      assert_response :unprocessable_content
    end

    test "changing the password signs out every other session" do
      other = @user.sessions.create!
      current = Current.session

      patch admin_account_path, params: { user: {
        current_password: "password", password: "un-secreto-nuevo", password_confirmation: "un-secreto-nuevo"
      } }

      assert_not Session.exists?(other.id)
      assert Session.exists?(current.id), "the session making the change should survive"
    end

    test "a student cannot reach the account screen" do
      sign_in_as users(:student)

      get edit_admin_account_path

      assert_redirected_to library_path
    end
  end
end
