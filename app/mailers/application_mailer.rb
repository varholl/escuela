class ApplicationMailer < ActionMailer::Base
  # Set MAILER_SENDER / CONTACT_RECIPIENT in the deployment environment; the
  # localhost defaults only ever apply in development.
  DEFAULT_SENDER = ENV.fetch("MAILER_SENDER", "hola@localhost")
  CONTACT_RECIPIENT = ENV.fetch("CONTACT_RECIPIENT", "hola@localhost")

  default from: DEFAULT_SENDER
  layout "mailer"

  # Until there is a domain to send from, nothing is delivered at all rather
  # than delivered badly. Every mailer inherits this, so a new one cannot forget.
  #
  # after_action, not before: building the message resets perform_deliveries
  # from the class setting, so anything set beforehand is overwritten.
  after_action { message.perform_deliveries = false unless Rails.configuration.x.email_enabled }

  def self.enabled?
    Rails.configuration.x.email_enabled
  end
end
