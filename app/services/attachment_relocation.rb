# Moves an uploaded file to a readable place in the bucket.
#
# Active Storage names every object with a random token, which is fine for the
# app and useless for a human opening the Cloudflare console. Direct uploads
# make it worse: the file reaches storage before the form is submitted, so at
# upload time we do not yet know which lesson it belongs to -- and for a new
# lesson, the lesson does not exist. So the object is put where it lands and
# moved once the record is saved and can say where it belongs.
#
# The move is a server-side copy: on R2 the bytes never travel to us and back,
# which for a video of several hundred megabytes is the difference between
# instant and expensive.
class AttachmentRelocation
  MAX_BASENAME = 60

  def initialize(blob, folder:)
    @blob = blob
    @folder = folder
  end

  def call
    return :unchanged if @folder.blank? || desired_key == @blob.key
    return :unsupported unless relocatable?

    copy_to desired_key
    previous_key = @blob.key
    # Point the record at the copy before removing the original: if anything
    # fails after this line the worst case is an orphan, never a lost file.
    @blob.update_column(:key, desired_key)
    remove previous_key

    :moved
  end

  private
    def desired_key
      @desired_key ||= begin
        candidate = "#{@folder}/#{readable_filename}"
        taken?(candidate) ? "#{@folder}/#{readable_basename}-#{SecureRandom.hex(4)}#{extension}" : candidate
      end
    end

    def readable_filename
      "#{readable_basename}#{extension}"
    end

    def readable_basename
      @blob.filename.base.parameterize.presence&.first(MAX_BASENAME) || "archivo"
    end

    def extension
      ext = @blob.filename.extension
      ext.present? ? ".#{ext.downcase}" : ""
    end

    def taken?(candidate)
      ActiveStorage::Blob.where(key: candidate).where.not(id: @blob.id).exists?
    end

    def service
      @blob.service
    end

    def relocatable?
      s3? || disk?
    end

    # Asked by capability rather than by class: the S3 service class is only
    # loaded when it is configured, so naming the constant would blow up in
    # test and development, where storage is on disk.
    def s3?
      service.respond_to?(:bucket)
    end

    def disk?
      service.respond_to?(:root)
    end

    def copy_to(key)
      if s3?
        bucket = service.bucket
        bucket.object(key).copy_from(bucket.object(@blob.key), multipart_copy: @blob.byte_size > 100.megabytes)
      else
        destination = service.send(:path_for, key)
        FileUtils.mkdir_p File.dirname(destination)
        FileUtils.cp service.send(:path_for, @blob.key), destination
      end
    end

    def remove(key)
      service.delete key
    end
end
