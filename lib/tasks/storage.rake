namespace :storage do
  desc "Move already-uploaded files into their folders (safe to re-run)"
  task organise: :environment do
    # Named here, not at the top: rake loads this file before the app's
    # constants exist.
    organised = [ Course, Lesson, Article, Page ]
    moved = unchanged = 0

    organised.each do |model|
      model.find_each do |record|
        folder = record.storage_folder
        next if folder.blank?

        record.owned_blobs.each do |blob|
          case AttachmentRelocation.new(blob, folder: folder).call
          when :moved
            moved += 1
            puts "  #{blob.key}"
          when :unchanged then unchanged += 1
          end
        end
      end
    end

    # Variants are generated lazily, long after the record was saved, so they
    # are tidied here rather than by the after_commit hook. They live beside the
    # original they were made from.
    ActiveStorage::VariantRecord.includes(:blob, image_attachment: :blob).find_each do |variant|
      folder = folder_for_original(variant.blob)
      next if folder.blank? || variant.image.blob.nil?

      case AttachmentRelocation.new(variant.image.blob, folder: "#{folder}/variantes").call
      when :moved then moved += 1
      when :unchanged then unchanged += 1
      end
    end

    puts "  movidos: #{moved}  ya estaban en su lugar: #{unchanged}"
  end

  desc "Delete uploads that were never attached to anything (abandoned forms)"
  task purge_orphans: :environment do
    grace = Integer(ENV.fetch("GRACE_HOURS", 24)).hours
    orphans = ActiveStorage::Blob.unattached.where(created_at: ..grace.ago)

    puts "  huérfanos con más de #{grace.inspect}: #{orphans.count}"
    orphans.find_each do |blob|
      puts "    #{blob.filename} (#{blob.key})"
      blob.purge_later
    end
  end

  # The folder of whatever the original file belongs to, so a thumbnail ends up
  # next to the photo it was made from.
  def folder_for_original(original)
    owner = original.attachments.first&.record
    owner.respond_to?(:storage_folder) ? owner.storage_folder : nil
  end

  desc "List every stored file and where it lives"
  task list: :environment do
    ActiveStorage::Blob.order(:key).find_each do |blob|
      owner = blob.attachments.first
      puts "  #{blob.key}"
      puts "      #{blob.filename} · #{ActiveSupport::NumberHelper.number_to_human_size(blob.byte_size)}" \
           " · #{owner ? "#{owner.record_type}##{owner.record_id}/#{owner.name}" : "sin dueño"}"
    end
    puts "  total: #{ActiveStorage::Blob.count}"
  end
end
