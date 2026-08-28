require "test_helper"

class InquiriesControllerTest < ActionDispatch::IntegrationTest
  setup { @course = Course.create!(title: "Fundamentos de atención plena", status: :published) }

  def valid_params(overrides = {})
    { inquiry: { name: "Ana", email: "ana@example.com", message: "Quiero saber más." }.merge(overrides) }
  end

  test "new renders the form" do
    get new_contact_path

    assert_response :success
    assert_select "form[action=?]", contact_path
  end

  test "new preselects the course named in the query string" do
    get new_contact_path(course: @course.slug)

    assert_select "option[selected][value=?]", @course.id.to_s
  end

  test "create stores the message and notifies" do
    assert_difference -> { Inquiry.count }, 1 do
      assert_enqueued_emails 1 do
        post contact_path, params: valid_params
      end
    end

    assert_redirected_to new_contact_path
    assert_equal "ana@example.com", Inquiry.last.email
    assert_equal "es", Inquiry.last.locale
  end

  test "create records the locale the visitor was reading in" do
    post contact_path, params: valid_params

    assert_equal "es", Inquiry.last.locale
  end

  test "create re-renders the form when the email is missing" do
    assert_no_difference -> { Inquiry.count } do
      post contact_path, params: valid_params(email: "")
    end

    assert_response :unprocessable_content
    assert_select "div[role=alert]"
  end

  test "a filled honeypot is silently discarded" do
    assert_no_difference -> { Inquiry.count } do
      assert_enqueued_emails 0 do
        post contact_path, params: valid_params(website: "https://spam.example")
      end
    end

    # The bot is told the same thing a person would be told.
    assert_redirected_to new_contact_path
  end

  test "the message is still stored when notifications are switched off" do
    Rails.configuration.x.email_enabled = false

    assert_difference -> { Inquiry.count }, 1 do
      assert_enqueued_emails 0 do
        post contact_path, params: valid_params
      end
    end

    assert_redirected_to new_contact_path
  ensure
    Rails.configuration.x.email_enabled = true
  end

  test "create attaches the chosen course" do
    post contact_path, params: valid_params(course_id: @course.id)

    assert_equal @course, Inquiry.last.course
  end
end
