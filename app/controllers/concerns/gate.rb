# The school is not open yet.
#
# Until the sample copy has been replaced with her own, the site answers two
# kinds of visitor. Someone with an account sees it whole, because she is the
# one who created that account. Everyone else gets a holding page at the root
# and nothing else: every other public path bounces back to it.
#
# What stays open with the doors shut is only what someone at the door needs:
# the way in (signing in, recovering a password), the contact form, robots.txt,
# and the error pages. Anything that already asks for a session of its own --
# the panel, the library -- opts out too, because there the sign-in redirect is
# more useful than a bounce to the holding page, and authentication is the
# stronger door anyway.
#
# It is one switch rather than a branch per page, so opening the site is setting
# OPEN_TO_VISITORS=true, and removing the gate for good is deleting this file,
# its skips, and the two views named after it.
module Gate
  extend ActiveSupport::Concern

  included do
    before_action :hold_at_the_gate
    helper_method :gated?
  end

  class_methods do
    def allow_gated_access(**options)
      skip_before_action :hold_at_the_gate, **options
    end
  end

  private
    # Whether the visitor in front of us is being held at the door.
    def gated?
      Rails.configuration.x.gated && !authenticated?
    end

    # 303 rather than 302 because this also catches form submissions -- the
    # registration that is closed while the site is -- and Turbo follows a
    # redirect after a POST only when it is told to see something else.
    def hold_at_the_gate
      redirect_to root_path, status: :see_other if gated?
    end
end
