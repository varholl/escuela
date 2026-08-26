class OrganiseAttachmentsJob < ApplicationJob
  queue_as :default

  # Active Storage analyses every new upload in its own job, reading the object
  # at the key it was uploaded to. Moving the object first makes that job fail
  # with NoSuchKey, and the two are enqueued from the same commit, so the order
  # is whatever the workers pick. Rather than race it, wait: the file stays at
  # its random key for a few seconds longer and nothing fails.
  #
  # Bounded, because an analysis that errors out would otherwise keep the file
  # unorganised forever. After the last attempt the move happens regardless.
  ATTEMPTS_WAITING_FOR_ANALYSIS = 5
  WAIT_BETWEEN_ATTEMPTS = 30.seconds

  # A record that vanished between saving and running is not an error.
  discard_on ActiveJob::DeserializationError

  def perform(record, attempt: 1)
    folder = record.storage_folder
    return if folder.blank?

    blobs = record.owned_blobs
    return if blobs.empty?

    if attempt < ATTEMPTS_WAITING_FOR_ANALYSIS && blobs.any? { |blob| !blob.analyzed? }
      return self.class.set(wait: WAIT_BETWEEN_ATTEMPTS).perform_later(record, attempt: attempt + 1)
    end

    blobs.each { |blob| AttachmentRelocation.new(blob, folder: folder).call }
  end
end
