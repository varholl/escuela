# Served by the app rather than from public/ so it follows the same switch as
# the robots meta tag; a static file would be served first and never change.
class RobotsController < ApplicationController
  # A crawler that cannot read robots.txt has not been told to stay out.
  allow_gated_access

  def show
    render plain: indexable? ? welcoming : closed, content_type: "text/plain"
  end

  private
    # Both switches have to be open. There is nothing to index behind a site
    # that answers every visitor with a holding page, so a stray
    # ALLOW_INDEXING=true before the doors open changes nothing here.
    def indexable?
      Rails.configuration.x.allow_indexing && !Rails.configuration.x.gated
    end

    def welcoming
      <<~TXT
        User-agent: *
        Disallow: /admin
        Disallow: /session
        Disallow: /passwords
      TXT
    end

    # While the site still carries sample copy, nothing should be indexed.
    def closed
      <<~TXT
        User-agent: *
        Disallow: /
      TXT
    end
end
