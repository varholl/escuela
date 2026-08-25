require "test_helper"

class LibraryControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course = Course.create!(title: "Atención plena", status: :published)
    @student = users(:student)
  end

  test "signing in is required" do
    get library_path

    assert_redirected_to new_session_path
  end

  test "an empty shelf invites her to look around" do
    sign_in_as @student

    get library_path

    assert_response :success
    assert_select "p", text: I18n.t("library.empty")
  end

  test "lists the courses she has joined" do
    @course.join!(@student)
    other = Course.create!(title: "Sin inscribir", status: :published)
    sign_in_as @student

    get library_path

    assert_select "h2", text: @course.title
    assert_select "h2", text: other.title, count: 0
  end

  test "an expired enrollment drops off the shelf" do
    @course.enrollments.create!(user: @student, status: :active, expires_at: 1.hour.ago)
    sign_in_as @student

    get library_path

    assert_select "h2", text: @course.title, count: 0
  end
end
