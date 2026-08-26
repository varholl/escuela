# Gives a record a folder in the bucket and keeps its files inside it.
#
# The work runs after commit, and in the background, because relocating happens
# once per upload and must never make saving a lesson feel slow or fail.
module OrganisedAttachments
  extend ActiveSupport::Concern

  included do
    after_commit :organise_attachments, on: %i[ create update ]
  end

  # Where this record's files belong, e.g. "cursos/atencion-plena/respirar".
  # Blank means "leave them where they are".
  def storage_folder
    nil
  end

  # Every blob this record owns: its attachments, plus anything embedded in its
  # rich text, which is how a PDF in a lesson's material gets here too.
  def owned_blobs
    attachment_blobs + rich_text_blobs
  end

  private
    def organise_attachments
      return if storage_folder.blank?
      # Most saves touch no files at all; a couple of queries here is cheaper
      # than a job per save, and these are admin-only writes.
      return if owned_blobs.none?

      OrganiseAttachmentsJob.perform_later(self)
    end

    def attachment_blobs
      self.class.attachment_reflections.keys.flat_map do |name|
        Array(public_send(name).then { |a| a.respond_to?(:blobs) ? a.blobs : a.blob })
      end.compact
    end

    def rich_text_blobs
      self.class.reflect_on_all_associations(:has_one)
        .filter_map { |reflection| reflection.name if reflection.name.to_s.start_with?("rich_text_") }
        .flat_map { |name| public_send(name)&.embeds&.to_a || [] }
        .filter_map(&:blob)
    end
end
