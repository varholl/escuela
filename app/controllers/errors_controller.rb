# Reached through config.exceptions_app, never by an ordinary link, so the
# actions render a status rather than a happy page.
class ErrorsController < ApplicationController
  def not_found
    render_error :not_found
  end

  def unprocessable
    render_error :unprocessable_content
  end

  def server_error
    render_error :internal_server_error
  end

  private
    def render_error(status)
      render "errors/show", status: status, locals: { status: status }
    end

    # The request being rendered is the synthetic /404; the locale the visitor
    # was actually reading in is only visible on the path they asked for.
    def requested_locale
      original_path = request.env["action_dispatch.original_path"] || request.path
      prefix = original_path.split("/").reject(&:blank?).first

      prefix.to_s.in?(I18n.available_locales.map(&:to_s)) ? prefix : I18n.default_locale
    end
end
