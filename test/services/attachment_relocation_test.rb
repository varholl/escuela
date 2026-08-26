require "test_helper"

class AttachmentRelocationTest < ActiveSupport::TestCase
  def blob_for(filename, content_type: "video/mp4")
    ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new("bytes"), filename: filename, content_type: content_type
    )
  end

  test "moves the object to a readable key inside the folder" do
    blob = blob_for("Primera Práctica.MP4")

    assert_equal :moved, AttachmentRelocation.new(blob, folder: "cursos/atencion-plena/respirar").call
    assert_equal "cursos/atencion-plena/respirar/primera-practica.mp4", blob.reload.key
  end

  test "the file is still readable at its new key" do
    blob = blob_for("clase.mp4")

    AttachmentRelocation.new(blob, folder: "cursos/x/y").call

    assert_equal "bytes", blob.reload.download
  end

  test "the old object is removed" do
    blob = blob_for("clase.mp4")
    original = blob.key

    AttachmentRelocation.new(blob, folder: "cursos/x/y").call

    assert_not blob.service.exist?(original)
  end

  test "running twice changes nothing the second time" do
    blob = blob_for("clase.mp4")

    assert_equal :moved, AttachmentRelocation.new(blob, folder: "cursos/x/y").call
    assert_equal :unchanged, AttachmentRelocation.new(blob.reload, folder: "cursos/x/y").call
  end

  test "a blank folder leaves the object alone" do
    blob = blob_for("clase.mp4")
    original = blob.key

    assert_equal :unchanged, AttachmentRelocation.new(blob, folder: nil).call
    assert_equal original, blob.reload.key
  end

  test "two files with the same name in one folder do not collide" do
    first = blob_for("clase.mp4")
    second = blob_for("clase.mp4")

    AttachmentRelocation.new(first, folder: "cursos/x/y").call
    AttachmentRelocation.new(second, folder: "cursos/x/y").call

    assert_equal "cursos/x/y/clase.mp4", first.reload.key
    assert_not_equal first.key, second.reload.key
    assert_match %r{\Acursos/x/y/clase-[0-9a-f]{8}\.mp4\z}, second.key
    assert_equal "bytes", second.download
  end

  test "an unnameable filename still gets a key" do
    blob = blob_for("...mp4")

    AttachmentRelocation.new(blob, folder: "cursos/x/y").call

    assert blob.reload.key.start_with?("cursos/x/y/")
  end

  test "a very long filename is trimmed" do
    blob = blob_for("#{'a' * 200}.mp4")

    AttachmentRelocation.new(blob, folder: "cursos/x/y").call

    assert_operator blob.reload.key.length, :<, 120
    assert blob.key.end_with?(".mp4")
  end
end
