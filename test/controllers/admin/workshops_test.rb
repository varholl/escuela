require "test_helper"

module Admin
  # Workshops are edited through the course form, which grows a video section
  # for them.
  class WorkshopsTest < ActionDispatch::IntegrationTest
    setup do
      sign_in_as users(:owner)
    end

    test "the course list offers a new workshop" do
      get admin_courses_path

      assert_select "a[href=?]", new_admin_course_path(kind: "workshop")
    end

    test "the new workshop form carries the video, uploaded directly" do
      get new_admin_course_path(kind: "workshop")

      assert_response :success
      assert_select "h1", text: "Nuevo taller"
      assert_select "input[type=hidden][name=?][value=workshop]", "course[kind]"
      assert_select "select[name=?]", "course[recording_attributes][video_provider]"
      # Without direct_upload the file would be buffered through the app.
      assert_select "input[type=file][name=?][data-direct-upload-url]", "course[recording_attributes][video]"
    end

    test "a new workshop is recorded on demand by default" do
      get new_admin_course_path(kind: "workshop")

      assert_select "select[name=?] option[selected][value=on_demand]", "course[modality]"
    end

    test "the course form has no video section" do
      get new_admin_course_path

      assert_select "select[name=?]", "course[recording_attributes][video_provider]", count: 0
    end

    test "creating a workshop with a youtube link" do
      assert_difference -> { Course.workshop.count } => 1, -> { Lesson.count } => 1 do
        post admin_courses_path, params: { course: {
          kind: "workshop", title: "Charla sobre el insomnio", status: "published",
          recording_attributes: { video_provider: "youtube", video_reference: "https://youtu.be/ihmc2fKshLA" }
        } }
      end

      workshop = Course.workshop.last
      assert_redirected_to edit_admin_course_path(workshop)
      assert_equal "Taller creado.", flash[:notice]
      assert_equal "https://youtu.be/ihmc2fKshLA", workshop.recording.video_reference
    end

    test "editing a workshop never turns it into a course" do
      workshop = Course.create!(title: "Charla", kind: :workshop)

      patch admin_course_path(workshop), params: { course: { kind: "course", title: "Charla" } }

      assert workshop.reload.workshop?
    end

    test "the workshop's video can be removed" do
      workshop = Course.create!(title: "Charla", kind: :workshop,
                                recording_attributes: { video_provider: "active_storage" })
      workshop.recording.video.attach(io: StringIO.new("bytes"), filename: "charla.mp4", content_type: "video/mp4")

      assert_changes -> { workshop.reload.recording.video.attached? }, from: true, to: false do
        patch admin_course_path(workshop), params: { course: {
          title: "Charla", recording_attributes: { remove_video: "1" }
        } }
        perform_enqueued_jobs
      end
    end

    test "a course ignores any recording sent with it" do
      assert_no_difference -> { Lesson.count } do
        post admin_courses_path, params: { course: {
          title: "Curso", recording_attributes: { video_provider: "youtube", video_reference: "x" }
        } }
      end

      assert Course.last.course?
    end

    test "a workshop has no lessons to manage" do
      workshop = Course.create!(title: "Charla", kind: :workshop)

      get edit_admin_course_path(workshop)

      assert_select "a[href=?]", admin_course_lessons_path(workshop), count: 0
    end
  end
end
