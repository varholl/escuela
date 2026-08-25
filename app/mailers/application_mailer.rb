class ApplicationMailer < ActionMailer::Base
  # Set MAILER_SENDER / CONTACT_RECIPIENT in the deployment environment; the
  # localhost defaults only ever apply in development.
  DEFAULT_SENDER = ENV.fetch("MAILER_SENDER", "hola@localhost")
  CONTACT_RECIPIENT = ENV.fetch("CONTACT_RECIPIENT", "hola@localhost")

  default from: DEFAULT_SENDER
  layout "mailer"
end
