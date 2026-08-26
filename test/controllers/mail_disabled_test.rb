require "test_helper"

# What the site does while there is no way to send mail. Nothing may break, and
# nothing may claim to have sent something.
class MailDisabledTest < ActionDispatch::IntegrationTest
  setup { Rails.configuration.x.email_enabled = false }
  teardown { Rails.configuration.x.email_enabled = true }

  test "signing up still works and sends nothing" do
    assert_difference -> { User.count }, 1 do
      assert_no_difference -> { ActionMailer::Base.deliveries.size } do
        perform_enqueued_jobs do
          post registration_path, params: { user: {
            name: "Ana", email_address: "ana@example.com",
            password: "una-clave-larga", password_confirmation: "una-clave-larga"
          } }
        end
      end
    end

    assert_redirected_to library_path
  end

  test "the sign-in screen does not offer password recovery" do
    get new_session_path

    assert_select "a[href=?]", new_password_path, count: 0
    assert_select "a[href=?]", new_contact_path
  end

  test "reaching password recovery directly says so instead of pretending" do
    get new_password_path

    assert_redirected_to new_session_path
    follow_redirect!
    assert_select "div", text: /#{I18n.t("passwords.unavailable")}/
  end

  test "the contact form still records the message" do
    assert_difference -> { Inquiry.count }, 1 do
      post contact_path, params: { inquiry: {
        name: "Ana", email: "ana@example.com", message: "Hola"
      } }
    end
  end
end

class MailEnabledTest < ActionDispatch::IntegrationTest
  test "signing up welcomes the student" do
    assert_enqueued_email_with StudentMailer, :welcome, args: ->(args) { args.first.email_address == "ana@example.com" } do
      post registration_path, params: { user: {
        name: "Ana", email_address: "ana@example.com",
        password: "una-clave-larga", password_confirmation: "una-clave-larga"
      } }
    end
  end

  test "the welcome mail is queued in the language the visitor was reading" do
    post registration_path(locale: "en"), params: { user: {
      name: "Ann", email_address: "ann@example.com",
      password: "una-clave-larga", password_confirmation: "una-clave-larga"
    } }

    assert_equal "en", enqueued_jobs.last["locale"]
  end

  test "granting access by hand tells the student" do
    sign_in_as users(:owner)
    course = Course.create!(title: "Atención plena", status: :published)

    assert_enqueued_email_with StudentMailer, :enrolled, args: ->(args) { args.first.course == course } do
      post admin_course_enrollments_path(course),
        params: { enrollment: { email_address: users(:student).email_address } }
    end
  end

  test "the sign-in screen offers password recovery" do
    get new_session_path

    assert_select "a[href=?]", new_password_path
  end
end
