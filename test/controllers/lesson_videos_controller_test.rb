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

  test "an enrolled student is handed a signed link to the file" do
    @course.join!(@student)
    sign_in_as @student

    get video_course_lesson_path(course_id: @course, id: @lesson)

    # Redirecting keeps the bytes off this machine; Fly bills egress, R2 does not.
    assert_response :redirect
    assert_match "practica.mp4", response.location
  end

  test "proxy delivery streams the bytes instead of redirecting" do
    @course.join!(@student)
    sign_in_as @student

    with_video_delivery("proxy") do
      get video_course_lesson_path(course_id: @course, id: @lesson)
    end

    assert_response :success
    assert_equal "video/mp4", response.media_type
  end

  test "proxy delivery is refused to someone who is not enrolled" do
    sign_in_as @student

    with_video_delivery("proxy") do
      get video_course_lesson_path(course_id: @course, id: @lesson)
    end

    assert_response :forbidden
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

  private
    def with_video_delivery(mode)
      previous = ENV["VIDEO_DELIVERY"]
      ENV["VIDEO_DELIVERY"] = mode
      yield
    ensure
      ENV["VIDEO_DELIVERY"] = previous
    end
end
