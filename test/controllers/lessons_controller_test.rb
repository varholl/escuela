require "test_helper"

class LessonsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course = Course.create!(title: "Atención plena", status: :published)
    @first = @course.lessons.create!(title: "Primera práctica", position: 1, published_at: 1.day.ago)
    @second = @course.lessons.create!(title: "Segunda práctica", position: 2, published_at: 1.day.ago)
    @student = users(:student)
  end

  test "a stranger is turned away and told why" do
    get course_lesson_path(course_id: @course, id: @first)

    assert_redirected_to course_path(id: @course)
    follow_redirect!
    assert_select "div", text: /#{I18n.t("lessons.show.locked")}/
  end

  test "a signed-in visitor who is not enrolled is turned away" do
    sign_in_as @student

    get course_lesson_path(course_id: @course, id: @first)

    assert_redirected_to course_path(id: @course)
  end

  test "an enrolled student can watch" do
    @course.join!(@student)
    sign_in_as @student

    get course_lesson_path(course_id: @course, id: @first)

    assert_response :success
    assert_select "h1", text: @first.title
  end

  test "an open session is watchable by anyone" do
    @first.update!(free_preview: true)

    get course_lesson_path(course_id: @course, id: @first)

    assert_response :success
  end

  test "an unpublished lesson stays shut even for an enrolled student" do
    @course.join!(@student)
    sign_in_as @student
    @first.update!(published_at: nil)

    get course_lesson_path(course_id: @course, id: @first)

    assert_redirected_to course_path(id: @course)
  end

  test "the next link only points at lessons the reader may open" do
    @course.join!(@student)
    sign_in_as @student

    get course_lesson_path(course_id: @course, id: @first)

    assert_select "a[href=?]", course_lesson_path(course_id: @course, id: @second)
  end

  test "there is no next link on the last lesson" do
    @course.join!(@student)
    sign_in_as @student

    get course_lesson_path(course_id: @course, id: @second)

    assert_select "a[href=?]", course_lesson_path(course_id: @course, id: @first)
    assert_select "a[href=?]", course_lesson_path(course_id: @course, id: @second), count: 0
  end

  test "a youtube reference becomes a privacy-preserving embed" do
    @first.update!(video_provider: "youtube", video_reference: "https://youtu.be/dQw4w9WgXcQ")
    @course.join!(@student)
    sign_in_as @student

    get course_lesson_path(course_id: @course, id: @first)

    assert_select "iframe[src=?]", "https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ?rel=0"
  end

  test "a lesson from another course is not reachable through this one" do
    other = Course.create!(title: "Otro", status: :published)
    stray = other.lessons.create!(title: "Ajena", published_at: 1.day.ago)

    get course_lesson_path(course_id: @course, id: stray)

    assert_response :not_found
  end
end
