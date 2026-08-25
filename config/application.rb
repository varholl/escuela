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
  end
end
