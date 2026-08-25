require "test_helper"

class EnrollmentsControllerTest < ActionDispatch::IntegrationTest
  setup { @course = Course.create!(title: "Atención plena", status: :published) }

  test "a visitor who is not signed in is asked to sign in" do
    assert_no_difference -> { Enrollment.count } do
      post course_enrollment_path(course_id: @course)
    end

    assert_redirected_to new_session_path
  end

  test "a signed-in visitor joins a free course" do
    sign_in_as users(:student)

    assert_difference -> { Enrollment.count }, 1 do
      post course_enrollment_path(course_id: @course)
    end

    assert_redirected_to course_path(id: @course)
    assert @course.reload.enrolled?(users(:student))
  end

  test "joining twice does not create a second enrollment" do
    sign_in_as users(:student)
    @course.join!(users(:student))

    assert_no_difference -> { Enrollment.count } do
      post course_enrollment_path(course_id: @course)
    end

    assert_redirected_to course_path(id: @course)
  end

  test "a paid course cannot be joined this way" do
    @course.update!(price_cents: 10_000_00)
    sign_in_as users(:student)

    assert_no_difference -> { Enrollment.count } do
      post course_enrollment_path(course_id: @course)
    end

    assert_redirected_to course_path(id: @course)
  end

  test "an unpublished course is not reachable at all" do
    @course.draft!
    sign_in_as users(:student)

    post course_enrollment_path(course_id: @course)

    assert_response :not_found
  end
end
