require "test_helper"

# Deleting a lesson must not leave its video paying rent in the bucket forever.
class AttachmentCleanupTest < ActiveSupport::TestCase
  setup { @course = Course.create!(title: "Atención plena", status: :published) }

  def lesson_with_files
    lesson = @course.lessons.create!(title: "Primera práctica")
    lesson.video.attach(io: StringIO.new("video"), filename: "clase.mp4", content_type: "video/mp4")
    embed = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new("pdf"), filename: "guia.pdf", content_type: "application/pdf"
    )
    lesson.notes = ActionText::Content.new.append_attachables(embed)
    perform_enqueued_jobs { lesson.save! }

    [ lesson.reload, lesson.video.blob, embed.reload ]
  end

  test "deleting a lesson deletes its video" do
    lesson, video, = lesson_with_files
    key = video.key

    perform_enqueued_jobs { lesson.destroy! }

    assert_not ActiveStorage::Blob.exists?(video.id), "the blob record survived"
    assert_not video.service.exist?(key), "the file is still in the bucket"
  end

  test "deleting a lesson deletes the files embedded in its material" do
    lesson, _video, embed = lesson_with_files
    key = embed.key

    perform_enqueued_jobs { lesson.destroy! }

    assert_not ActiveStorage::Blob.exists?(embed.id), "the embedded file's blob survived"
    assert_not embed.service.exist?(key), "the embedded file is still in the bucket"
  end

  test "deleting a course takes its lessons' files with it" do
    _lesson, video, embed = lesson_with_files
    @course.cover_image.attach(io: StringIO.new("img"), filename: "portada.jpg", content_type: "image/jpeg")
    perform_enqueued_jobs { @course.save! }
    cover = @course.reload.cover_image.blob
    keys = [ video.key, embed.key, cover.key ]

    perform_enqueued_jobs { @course.destroy! }

    keys.each { |key| assert_not cover.service.exist?(key), "#{key} is still in the bucket" }
    assert_equal 0, ActiveStorage::Blob.where(id: [ video.id, embed.id, cover.id ]).count
  end

  test "deleting an article deletes its cover" do
    article = Article.create!(title: "Respirar no es relajarse")
    article.cover_image.attach(io: StringIO.new("img"), filename: "foto.jpg", content_type: "image/jpeg")
    perform_enqueued_jobs { article.save! }
    blob = article.reload.cover_image.blob
    key = blob.key

    perform_enqueued_jobs { article.destroy! }

    assert_not blob.service.exist?(key)
  end

  test "removing just the video leaves the rest of the lesson alone" do
    lesson, video, embed = lesson_with_files
    key = video.key

    perform_enqueued_jobs { lesson.video.purge_later }

    assert_not video.service.exist?(key)
    assert ActiveStorage::Blob.exists?(embed.id), "the material should not be touched"
    assert Lesson.exists?(lesson.id)
  end
end
