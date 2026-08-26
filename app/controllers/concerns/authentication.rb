module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :require_authentication
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private
    def authenticated?
      resume_session
    end

    def require_authentication
      resume_session || request_authentication
    end

    def resume_session
      Current.session ||= find_session_by_cookie
    end

    def find_session_by_cookie
      Session.find_by(id: cookies.signed[:session_id]) if cookies.signed[:session_id]
    end

    def request_authentication
      session[:return_to_after_authenticating] = request.url
      redirect_to new_session_path
    end

    # A dónde va alguien recién autenticada.
    #
    # Se respeta la página que quiso abrir antes de que le pidiéramos entrar,
    # salvo que no tenga permiso para verla: si estando deslogueada abrió
    # /admin, mandarla de vuelta ahí sólo produce un "no tenés permiso" en la
    # cara apenas entra. En ese caso va a donde sí le sirve.
    def after_authentication_url(user = Current.user)
      requested = session.delete(:return_to_after_authenticating)
      return requested if requested.present? && reachable_after_signing_in?(requested, user)

      default_url_after_authenticating(user)
    end

    def default_url_after_authenticating(user)
      user&.admin? ? admin_root_url : library_url
    end

    # El panel es lo único cerrado por rol, así que es lo único que hay que
    # comprobar.
    def reachable_after_signing_in?(url, user)
      return true if user&.admin?

      !URI.parse(url).path.to_s.start_with?("/admin")
    rescue URI::InvalidURIError
      false
    end

    def start_new_session_for(user)
      user.sessions.create!(user_agent: request.user_agent, ip_address: request.remote_ip).tap do |session|
        Current.session = session
        cookies.signed.permanent[:session_id] = { value: session.id, httponly: true, same_site: :lax }
      end
    end

    def terminate_session
      Current.session.destroy
      cookies.delete(:session_id)
    end
end
