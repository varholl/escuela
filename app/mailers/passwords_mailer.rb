class PasswordsMailer < ApplicationMailer
  def reset(user)
    @user = user

    mail to: user.email_address, subject: t("passwords_mailer.reset.subject")
  end
end
