class InquiryMailer < ApplicationMailer
  def notify(inquiry)
    @inquiry = inquiry

    mail to: ApplicationMailer::CONTACT_RECIPIENT,
         reply_to: inquiry.email,
         subject: "[#{Rails.application.class.module_parent_name}] #{I18n.t('inquiry_mailer.notify.subject', name: inquiry.name)}"
  end
end
