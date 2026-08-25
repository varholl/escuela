namespace :mail do
  desc "Report how mail is configured right now"
  task status: :environment do
    puts "  environment:   #{Rails.env}"
    puts "  delivery:      #{ActionMailer::Base.delivery_method}"
    puts "  notifications: #{Rails.configuration.x.deliver_inquiry_notifications ? "on" : "off"}"
    puts "  from:          #{ApplicationMailer::DEFAULT_SENDER}"
    puts "  contact goes to: #{ApplicationMailer::CONTACT_RECIPIENT}"

    settings = ActionMailer::Base.smtp_settings
    if settings[:address].present?
      puts "  smtp:          #{settings[:user_name]}@#{settings[:address]}:#{settings[:port]}"
    else
      puts "  smtp:          not configured -- set SMTP_ADDRESS and friends"
    end
  end

  desc "Send a real message to CONTACT_RECIPIENT to prove delivery works"
  task test: :environment do
    inquiry = Inquiry.new(
      name: "Prueba de configuración",
      email: ApplicationMailer::CONTACT_RECIPIENT,
      message: "Si estás leyendo esto, el correo del formulario de contacto funciona.\n\n" \
               "Enviado desde #{Rails.env} el #{I18n.l(Time.current, format: :long)}."
    )

    # Delivered inline rather than enqueued so a failure surfaces here instead of
    # disappearing into the job queue.
    InquiryMailer.notify(inquiry).deliver_now
    puts "  sent to #{ApplicationMailer::CONTACT_RECIPIENT}"
  rescue StandardError => e
    puts "  FAILED: #{e.class}: #{e.message}"
    raise
  end
end
