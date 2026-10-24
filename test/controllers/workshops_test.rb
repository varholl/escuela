require "test_helper"

class WorkshopsTest < ActionDispatch::IntegrationTest
  setup do
    @workshop = Course.create!(title: "Charla sobre el insomnio", kind: :workshop, status: :published,
                               price_cents: 15_000_00,
                               recording_attributes: { video_provider: "youtube", video_reference: "ihmc2fKshLA" })
    @student = users(:student)
  end

  test "the courses page lists workshops in a section of their own" do
    course = Course.create!(title: "Fundamentos de atención plena", status: :published)

    get courses_path

    assert_select "#workshops-title"
    assert_select "section[aria-labelledby=workshops-title] h3", text: @workshop.title
    assert_select "section[aria-labelledby=workshops-title] h3", text: course.title, count: 0
  end

  test "no workshops, no workshop section" do
    @workshop.update!(status: :draft)

    get courses_path

    assert_select "#workshops-title", count: 0
  end

  test "a stranger sees that there is a video, not the video" do
    get course_path(id: @workshop)

    assert_response :success
    assert_select "#video", text: /inscribirte/
    assert_select "iframe", count: 0
    assert_no_match "ihmc2fKshLA", response.body
  end

  test "a paid workshop sends the reader to the contact form, like a paid course" do
    get course_path(id: @workshop)

    assert_select "a[href=?]", new_contact_path(course: @workshop.slug)
  end

  test "an enrolled student watches it on the workshop's page" do
    @workshop.join!(@student)
    sign_in_as @student

    get course_path(id: @workshop)

    assert_select "#video iframe[src=?]", "https://www.youtube-nocookie.com/embed/ihmc2fKshLA?rel=0"
    assert_select "a[href=?]", "#video", text: "Ver el taller"
  end

  test "a workshop without its video yet says so" do
    @workshop.recording.update!(video_provider: nil, video_reference: nil)
    @workshop.join!(@student)
    sign_in_as @student

    get course_path(id: @workshop)

    assert_select "#video", text: /se publica pronto/
  end

  test "the recording has no page of its own" do
    get course_lesson_path(course_id: @workshop, id: @workshop.recording)

    assert_redirected_to course_path(id: @workshop, anchor: "video")
  end

  test "an uploaded recording stays behind the enrollment" do
    @workshop.recording.update!(video_provider: "active_storage")
    @workshop.recording.video.attach(io: StringIO.new("bytes"), filename: "charla.mp4", content_type: "video/mp4")
    sign_in_as @student

    get video_course_lesson_path(course_id: @workshop, id: @workshop.recording)

    assert_response :forbidden
  end

  test "a student's library sends them straight to the video" do
    @workshop.join!(@student)
    sign_in_as @student

    get library_path

    assert_select "a[href=?]", course_path(id: @workshop, anchor: "video")
  end
end
