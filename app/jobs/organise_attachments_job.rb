class OrganiseAttachmentsJob < ApplicationJob
  queue_as :default

  # A record that vanished between saving and running is not an error.
  discard_on ActiveJob::DeserializationError

  def perform(record)
    folder = record.storage_folder
    return if folder.blank?

    record.owned_blobs.each do |blob|
      AttachmentRelocation.new(blob, folder: folder).call
    end
  end
end
