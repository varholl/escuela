require "test_helper"

# An uploaded video must be as private as the page it sits on: Active Storage's
# own signed URL is shareable, which is the leak this route exists to close.
class LessonVideosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @course = Course.create!(title: "Atención plena", status: :published)
    @lesson = @course.lessons.create!(title: "Primera práctica", published_at: 1.day.ago,
                                      video_provider: "active_storage")
    @lesson.video.attach(
      io: StringIO.new("not really a video"),
      filename: "practica.mp4",
      content_type: "video/mp4"
    )
    @student = users(:student)
  end

  test "a stranger cannot fetch the bytes" do
    get video_course_lesson_path(course_id: @course, id: @lesson)

    assert_response :forbidden
  end

  test "an account alone is not enough" do
    sign_in_as @student

    get video_course_lesson_path(course_id: @course, id: @lesson)

    assert_response :forbidden
  end

  test "an enrolled student gets the video" do
    @course.join!(@student)
    sign_in_as @student

    get video_course_lesson_path(course_id: @course, id: @lesson)

    assert_response :success
    assert_equal "video/mp4", response.media_type
  end

  test "an unpublished lesson stays closed even to an enrolled student" do
    @course.join!(@student)
    sign_in_as @student
    @lesson.update!(published_at: nil)

    get video_course_lesson_path(course_id: @course, id: @lesson)

    assert_response :forbidden
  end

  test "a lesson with no video reports nothing there" do
    @lesson.video.purge
    @course.join!(@student)
    sign_in_as @student

    get video_course_lesson_path(course_id: @course, id: @lesson)

    assert_response :not_found
  end

  test "the player points at the gate, never at active storage" do
    @course.join!(@student)
    sign_in_as @student

    get course_lesson_path(course_id: @course, id: @lesson)

    assert_select "video source, video" do |elements|
      sources = elements.map { |e| e["src"] }.compact
      assert sources.any? { |src| src.include?("/video") }
      assert_empty sources.grep(/rails\/active_storage/),
        "the raw Active Storage URL must never reach the page"
    end
  end
end
