require "test_helper"

class StudentMailerTest < ActionMailer::TestCase
  setup { @course = Course.create!(title: "Atención plena", status: :published) }

  test "the welcome mail greets the student and points at her shelf" do
    mail = StudentMailer.welcome(users(:student))

    assert_equal [ users(:student).email_address ], mail.to
    assert_match I18n.t("site.name"), mail.subject
    assert_match users(:student).display_name, mail.html_part.body.to_s
    assert_match "mis-cursos", mail.html_part.body.to_s
  end

  test "the enrolment mail names the course and links to it" do
    enrollment = @course.join!(users(:student))

    mail = StudentMailer.enrolled(enrollment)

    assert_equal [ users(:student).email_address ], mail.to
    assert_match @course.title, mail.subject
    assert_match @course.slug, mail.html_part.body.to_s
  end

  test "every mail goes out in both a text and an html part" do
    mail = StudentMailer.welcome(users(:student))

    assert mail.text_part.present?, "a text part matters for deliverability"
    assert mail.html_part.present?
  end

  test "mail is written in the reader's language" do
    spanish = StudentMailer.welcome(users(:student)).subject
    english = I18n.with_locale(:en) { StudentMailer.welcome(users(:student)).subject }

    assert_not_equal spanish, english
    assert_match "bienvenida", spanish
    assert_match "Welcome", english
  end

  test "nothing is delivered while email is switched off" do
    Rails.configuration.x.email_enabled = false

    assert_no_difference -> { ActionMailer::Base.deliveries.size } do
      StudentMailer.welcome(users(:student)).deliver_now
    end
  ensure
    Rails.configuration.x.email_enabled = true
  end

  test "it is delivered once email is switched on" do
    assert_difference -> { ActionMailer::Base.deliveries.size }, 1 do
      StudentMailer.welcome(users(:student)).deliver_now
    end
  end
end
