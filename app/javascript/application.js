// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

// Direct uploads: a lesson video goes from the browser straight to R2 instead
// of through this app, which would otherwise buffer hundreds of megabytes.
import * as ActiveStorage from "@rails/activestorage"
ActiveStorage.start()

import "trix"
import "@rails/actiontext"
