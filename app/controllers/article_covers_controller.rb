# The cover of a note, on an address that does not expire.
#
# What goes into og:image has to survive being fetched long after the page was
# rendered: a crawler comes back for it every time the link is pasted somewhere
# new. Active Storage's own URLs last five minutes here -- deliberately, because
# the course material is private -- so linking one would give WhatsApp a picture
# that is already gone by the time anyone sees the message.
#
# The fix is the same one the institutional video uses: the address stays ours
# and the signed link is minted fresh on every request. The bucket stays private.
class ArticleCoversController < ApplicationController
  # Disk-service URLs need to know the host they are being generated for; in
  # production the R2 service builds its own absolute URL and ignores this.
  include ActiveStorage::SetCurrent

  # The size every social network crops to. `crop: :attention` lets libvips pick
  # the crop around the most salient part rather than the geometric centre.
  SOCIAL_CARD = [ 1200, 630, { crop: :attention } ].freeze

  def show
    article = Article.in_locale(I18n.locale).published.find_by(slug: params[:id])

    return head :not_found unless article&.cover_image&.attached?

    redirect_to article.cover_image.variant(resize_to_fill: SOCIAL_CARD).processed.url,
      allow_other_host: true
  end
end
