# Handing a video file to the browser, without ever linking Active Storage's own
# URL: its signed id can be passed on, which is exactly what the private courses
# are trying to prevent.
#
# Two ways to hand it over, because they trade off differently:
#
#   redirect (default)  A signed URL straight to the storage service. The bytes
#                       never touch this machine, so it costs nothing to serve
#                       -- egress from R2 is free, while egress from Fly in
#                       Sao Paulo is $0.04/GB.
#   proxy               Streamed through the app, so no usable URL ever leaves
#                       the server. Set VIDEO_DELIVERY=proxy.
#
# Whether a given video needs an enrollment is the caller's business; this only
# knows how to deliver one.
module VideoDelivery
  extend ActiveSupport::Concern

  included do
    include ActiveStorage::Streaming
    # Disk-service URLs need to know the host they are being generated for.
    include ActiveStorage::SetCurrent
  end

  # A signed link has to outlive the viewing session: seeking re-requests the
  # same URL, so an expiry shorter than the video breaks playback halfway.
  LINK_LIFETIME = Integer(ENV.fetch("VIDEO_LINK_MINUTES", 120)).minutes

  private
    def deliver_video(attachment)
      return head :not_found unless attachment.attached?

      if proxied_video?
        send_blob_stream attachment.blob, disposition: "inline"
      else
        redirect_to attachment.url(expires_in: LINK_LIFETIME), allow_other_host: true
      end
    end

    def proxied_video?
      ENV["VIDEO_DELIVERY"] == "proxy"
    end
end
