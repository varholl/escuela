require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Maflor
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 8.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    config.time_zone = "America/Argentina/Buenos_Aires"
    config.active_record.default_timezone = :utc

    # Spanish is the site's mother tongue; English is offered under an /en
    # prefix. Locale files are split into subdirectories, hence the glob.
    config.i18n.available_locales = %i[ es en ]
    config.i18n.default_locale = :es
    config.i18n.fallbacks = [ :es ]
    config.i18n.load_path += Dir[Rails.root.join("config/locales/**/*.{rb,yml}")]

    # Course material is private, so a signed storage URL that leaks should stop
    # working quickly rather than being a permanent key.
    config.active_storage.urls_expire_in = 5.minutes

    # Search engines are kept out until the copy is really hers. Flip with
    # ALLOW_INDEXING=true; see robots.txt and the layout's robots meta tag.
    config.x.allow_indexing = ENV.fetch("ALLOW_INDEXING", "false") == "true"

    # The one host the site answers on. Everything else -- www, the fly.dev
    # name, an old domain -- redirects here, so there is a single URL to share
    # and a single one for search engines to index.
    config.x.canonical_host = ENV["APP_HOST"].presence

    # Whether the app sends mail at all. False until SMTP is configured, which
    # needs a domain of its own: mail sent "from" a gmail.com address through
    # someone else's server fails DMARC alignment and lands in spam.
    #
    # Nothing depends on mail to work. The contact form always stores the
    # message, and students choose their own password when they sign up.
    config.x.email_enabled = true

    # Render error pages through the app so a stale link lands somewhere that
    # still looks like the site. public/*.html remains the fallback for the
    # case where the app itself cannot render.
    config.exceptions_app = routes
  end
end
