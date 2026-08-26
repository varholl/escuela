require "test_helper"

module Admin
  class LessonsControllerTest < ActionDispatch::IntegrationTest
    setup do
      sign_in_as users(:owner)
      @course = Course.create!(title: "Atención plena", status: :published)
      @lesson = @course.lessons.create!(title: "Primera práctica", position: 1)
    end

    def attach_video(lesson)
      lesson.video.attach(io: StringIO.new("bytes"), filename: "clase.mp4", content_type: "video/mp4")
      lesson
    end

    test "the form offers a direct upload field for the video" do
      get edit_admin_course_lesson_path(@course, @lesson)

      assert_response :success
      # Without direct_upload the file would be buffered through the app.
      assert_select "input[type=file][name=?][data-direct-upload-url]", "lesson[video]"
    end

    test "the form shows an attached video and offers to remove it" do
      attach_video(@lesson)

      get edit_admin_course_lesson_path(@course, @lesson)

      assert_select "span", text: "clase.mp4"
      assert_select "input[type=checkbox][name=?]", "lesson[remove_video]"
    end

    test "a lesson with no video does not offer to remove one" do
      get edit_admin_course_lesson_path(@course, @lesson)

      assert_select "input[name=?]", "lesson[remove_video]", count: 0
    end

    test "ticking remove detaches the video" do
      attach_video(@lesson)

      assert_changes -> { @lesson.reload.video.attached? }, from: true, to: false do
        patch admin_course_lesson_path(@course, @lesson),
          params: { lesson: { title: @lesson.title, remove_video: "1" } }
        perform_enqueued_jobs
      end
    end

    test "leaving remove unticked keeps the video" do
      attach_video(@lesson)

      patch admin_course_lesson_path(@course, @lesson),
        params: { lesson: { title: "Otro título", remove_video: "0" } }

      assert @lesson.reload.video.attached?
      assert_equal "Otro título", @lesson.title
    end

    test "creating a lesson with a video" do
      blob = ActiveStorage::Blob.create_and_upload!(
        io: StringIO.new("bytes"), filename: "nueva.mp4", content_type: "video/mp4"
      )

      assert_difference -> { Lesson.count }, 1 do
        post admin_course_lessons_path(@course), params: {
          lesson: { title: "Segunda práctica", position: 2,
                    video_provider: "active_storage", video: blob.signed_id }
        }
      end

      assert_equal "nueva.mp4", Lesson.last.video.filename.to_s
    end
  end
end
