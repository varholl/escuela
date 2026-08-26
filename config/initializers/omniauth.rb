# Sign in with Google.
#
# The credentials come from the environment; without them the strategy is not
# registered at all, so development and test never accidentally talk to Google
# and the buttons simply do not appear.
if ENV["GOOGLE_CLIENT_ID"].present? && ENV["GOOGLE_CLIENT_SECRET"].present?
  Rails.application.config.middleware.use OmniAuth::Builder do
    provider :google_oauth2,
      ENV.fetch("GOOGLE_CLIENT_ID"),
      ENV.fetch("GOOGLE_CLIENT_SECRET"),
      scope: "email,profile",
      # No refresh token is needed: the app reads the profile once at sign-in
      # and never acts on the account afterwards.
      access_type: "online",
      prompt: "select_account"
  end

  Rails.application.config.x.google_sign_in = true
end

OmniAuth.config.allowed_request_methods = [ :post ]

# A failure must not show a stack trace to a visitor.
OmniAuth.config.on_failure = proc { |env|
  OmniauthCallbacksController.action(:failure).call(env)
}
