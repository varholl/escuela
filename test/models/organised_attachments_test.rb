require "test_helper"

class OrganisedAttachmentsTest < ActiveSupport::TestCase
  setup { @course = Course.create!(title: "Atención plena", status: :published) }

  test "a lesson video lands in the course and lesson folder" do
    lesson = @course.lessons.create!(title: "Primera práctica")
    lesson.video.attach(io: StringIO.new("bytes"), filename: "clase uno.mp4", content_type: "video/mp4")

    perform_enqueued_jobs { lesson.save! }

    assert_equal "cursos/atencion-plena/primera-practica/clase-uno.mp4",
      lesson.reload.video.blob.key
  end

  test "a file embedded in the lesson material lands there too" do
    lesson = @course.lessons.create!(title: "Primera práctica")
    blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new("pdf"), filename: "guia.pdf", content_type: "application/pdf"
    )
    lesson.notes = ActionText::Content.new.append_attachables(blob)

    perform_enqueued_jobs { lesson.save! }

    assert_equal "cursos/atencion-plena/primera-practica/guia.pdf", blob.reload.key
  end

  test "a course cover lands in the course folder" do
    @course.cover_image.attach(io: StringIO.new("img"), filename: "portada.jpg", content_type: "image/jpeg")

    perform_enqueued_jobs { @course.save! }

    assert_equal "cursos/atencion-plena/portada.jpg", @course.reload.cover_image.blob.key
  end

  test "an article cover lands under notas" do
    article = Article.create!(title: "Respirar no es relajarse")
    article.cover_image.attach(io: StringIO.new("img"), filename: "foto.jpg", content_type: "image/jpeg")

    perform_enqueued_jobs { article.save! }

    assert_equal "notas/respirar-no-es-relajarse/foto.jpg", article.reload.cover_image.blob.key
  end

  test "a page portrait lands under paginas, keyed by locale" do
    page = Page.create!(key: "about", locale: "es")
    page.cover_image.attach(io: StringIO.new("img"), filename: "retrato.jpg", content_type: "image/jpeg")

    perform_enqueued_jobs { page.save! }

    assert_equal "paginas/about-es/retrato.jpg", page.reload.cover_image.blob.key
  end

  test "the file still downloads after being moved" do
    lesson = @course.lessons.create!(title: "Primera práctica")
    lesson.video.attach(io: StringIO.new("contenido"), filename: "clase.mp4", content_type: "video/mp4")

    perform_enqueued_jobs { lesson.save! }

    assert_equal "contenido", lesson.reload.video.download
  end

  test "the move waits until Active Storage has finished analysing" do
    lesson = @course.lessons.create!(title: "Primera práctica")
    lesson.video.attach(io: StringIO.new("bytes"), filename: "clase.mp4", content_type: "video/mp4")
    lesson.save!
    blob = lesson.reload.video.blob
    blob.update!(metadata: {})
    original = blob.key

    # Moving now would break the analyser, which is still looking at this key.
    OrganiseAttachmentsJob.perform_now(lesson)

    assert_equal original, blob.reload.key, "the file moved out from under the analyser"
    assert_enqueued_with job: OrganiseAttachmentsJob
  end

  test "it gives up waiting rather than leaving a file unorganised forever" do
    lesson = @course.lessons.create!(title: "Primera práctica")
    lesson.video.attach(io: StringIO.new("bytes"), filename: "clase.mp4", content_type: "video/mp4")
    lesson.save!
    blob = lesson.reload.video.blob
    blob.update!(metadata: {})

    OrganiseAttachmentsJob.perform_now(lesson, attempt: OrganiseAttachmentsJob::ATTEMPTS_WAITING_FOR_ANALYSIS)

    assert_equal "cursos/atencion-plena/primera-practica/clase.mp4", blob.reload.key
  end

  test "saving a record with no files enqueues nothing" do
    lesson = @course.lessons.create!(title: "Sin archivos")

    assert_no_enqueued_jobs(only: OrganiseAttachmentsJob) do
      lesson.update!(summary: "cambio")
    end
  end
end
