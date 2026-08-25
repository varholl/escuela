require "test_helper"

module Admin
  # The panel is the one part of the site that is not public, so every entrance
  # to it is checked here rather than repeated in each controller's test.
  class AccessTest < ActionDispatch::IntegrationTest
    ENTRANCES = %i[
      admin_root_path admin_articles_path admin_courses_path
      admin_pages_path admin_inquiries_path
    ].freeze

    test "a visitor is sent to sign in" do
      ENTRANCES.each do |entrance|
        get public_send(entrance)
        assert_redirected_to new_session_path, "#{entrance} should require a session"
      end
    end

    test "a signed-in student is turned away" do
      sign_in_as users(:student)

      ENTRANCES.each do |entrance|
        get public_send(entrance)
        assert_redirected_to root_path, "#{entrance} should be admin-only"
      end
    end

    test "the owner gets in" do
      sign_in_as users(:owner)

      ENTRANCES.each do |entrance|
        get public_send(entrance)
        assert_response :success, "#{entrance} should be reachable by an admin"
      end
    end

    test "after signing in the visitor lands back where they were headed" do
      get admin_articles_path
      assert_redirected_to new_session_path

      post session_path, params: { email_address: users(:owner).email_address, password: "password" }

      assert_redirected_to admin_articles_url
    end
  end
end
