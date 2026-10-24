require "test_helper"

# A workshop is a course with one video. The video lives in a lesson the
# workshop keeps for itself -- its recording -- so these are about that lesson
# staying out of her way.
class WorkshopTest < ActiveSupport::TestCase
  def workshop(**attributes)
    Course.create!(title: "Charla sobre el insomnio", kind: :workshop, **attributes)
  end

  test "a workshop gets its recording when it is created" do
    created = workshop(recording_attributes: { video_provider: "youtube", video_reference: "ihmc2fKshLA" })

    assert_equal 1, created.lessons.count
    assert_equal "ihmc2fKshLA", created.recording.video_reference
  end

  test "the recording is published from the start, so the workshop alone decides who sees it" do
    assert workshop.recording.published?
  end

  test "the recording follows the workshop's title" do
    created = workshop

    created.update!(title: "Insomnio: escuchar al cuerpo")

    assert_equal "Insomnio: escuchar al cuerpo", created.reload.recording.title
  end

  test "editing the video replaces it rather than adding a second one" do
    created = workshop(recording_attributes: { video_provider: "youtube", video_reference: "ihmc2fKshLA" })

    created.update!(recording_attributes: { video_reference: "dQw4w9WgXcQ" })

    assert_equal 1, created.lessons.count
    assert_equal "dQw4w9WgXcQ", created.reload.recording.video_reference
  end

  test "editing the video of a workshop loaded afresh saves it" do
    id = workshop(recording_attributes: { video_provider: "youtube", video_reference: "ihmc2fKshLA" }).id

    Course.find(id).update!(recording_attributes: { video_reference: "dQw4w9WgXcQ" })

    assert_equal "dQw4w9WgXcQ", Course.find(id).recording.video_reference
  end

  test "a course is not given a recording" do
    course = Course.create!(title: "Fundamentos de atención plena")

    assert course.course?
    assert_equal 0, course.lessons.count
  end

  test "an enrolled student can watch the recording; a stranger cannot" do
    created = workshop(status: :published)
    student = users(:student)

    assert_not created.recording.viewable_by?(student)

    created.join!(student)

    assert created.reload.recording.viewable_by?(student)
  end
end
