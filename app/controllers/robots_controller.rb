# Served by the app rather than from public/ so it follows the same switch as
# the robots meta tag; a static file would be served first and never change.
class RobotsController < ApplicationController
  def show
    render plain: Rails.configuration.x.allow_indexing ? welcoming : closed,
           content_type: "text/plain"
  end

  private
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
