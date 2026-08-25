require "test_helper"

class LessonsHelperTest < ActionView::TestCase
  include LessonsHelper

  def lesson(provider:, reference:)
    Lesson.new(video_provider: provider, video_reference: reference)
  end

  test "accepts a full youtube watch url" do
    assert_equal "https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ?rel=0",
      lesson_embed_url(lesson(provider: "youtube", reference: "https://www.youtube.com/watch?v=dQw4w9WgXcQ"))
  end

  test "accepts a youtu.be share link" do
    assert_equal "https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ?rel=0",
      lesson_embed_url(lesson(provider: "youtube", reference: "https://youtu.be/dQw4w9WgXcQ"))
  end

  test "accepts a bare youtube id" do
    assert_equal "https://www.youtube-nocookie.com/embed/dQw4w9WgXcQ?rel=0",
      lesson_embed_url(lesson(provider: "youtube", reference: "dQw4w9WgXcQ"))
  end

  test "accepts a vimeo url or a bare number" do
    expected = "https://player.vimeo.com/video/123456789"
    assert_equal expected, lesson_embed_url(lesson(provider: "vimeo", reference: "https://vimeo.com/123456789"))
    assert_equal expected, lesson_embed_url(lesson(provider: "vimeo", reference: "123456789"))
  end

  test "surrounding whitespace from a paste is ignored" do
    assert_equal "https://player.vimeo.com/video/123456789",
      lesson_embed_url(lesson(provider: "vimeo", reference: "  https://vimeo.com/123456789  "))
  end

  test "returns nothing when there is no reference or no provider" do
    assert_nil lesson_embed_url(lesson(provider: "youtube", reference: ""))
    assert_nil lesson_embed_url(lesson(provider: nil, reference: "dQw4w9WgXcQ"))
  end

  test "reports whether a lesson has anything to play" do
    assert lesson_has_player?(lesson(provider: "vimeo", reference: "123456789"))
    assert_not lesson_has_player?(lesson(provider: "vimeo", reference: ""))
    assert_not lesson_has_player?(lesson(provider: "active_storage", reference: nil))
  end
end
