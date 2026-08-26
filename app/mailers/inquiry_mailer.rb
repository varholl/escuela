class InquiryMailer < ApplicationMailer
  def notify(inquiry)
    @inquiry = inquiry

    mail to: ApplicationMailer::CONTACT_RECIPIENT,
         reply_to: inquiry.email,
         subject: "[#{t("site.name")}] #{t("inquiry_mailer.notify.subject", name: inquiry.name)}"
  end
end
