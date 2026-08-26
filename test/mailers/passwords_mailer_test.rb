require "test_helper"

class PasswordsMailerTest < ActionMailer::TestCase
  test "the reset mail carries a working link and says when it expires" do
    mail = PasswordsMailer.reset(users(:owner))

    assert_equal [ users(:owner).email_address ], mail.to
    assert_equal I18n.t("passwords_mailer.reset.subject"), mail.subject
    assert_match "/passwords/", mail.html_part.body.to_s
    assert_match I18n.t("passwords_mailer.reset.ignore"), mail.text_part.body.to_s
  end

  test "it is in Spanish, not the generated English" do
    body = PasswordsMailer.reset(users(:owner)).html_part.body.to_s

    assert_match "contraseña", body
    assert_no_match(/reset your password on/i, body)
  end
end
