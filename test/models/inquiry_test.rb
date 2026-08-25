require "test_helper"

class InquiryTest < ActiveSupport::TestCase
  test "normalises the email and name" do
    inquiry = Inquiry.create!(name: "  Ana  ", email: "  ANA@Example.COM ", message: "Hola")

    assert_equal "Ana", inquiry.name
    assert_equal "ana@example.com", inquiry.email
  end

  test "requires a plausible email" do
    assert_not Inquiry.new(name: "Ana", email: "no-es-un-correo", message: "Hola").valid?
  end

  test "a course is optional" do
    assert Inquiry.new(name: "Ana", email: "ana@example.com", message: "Hola").valid?
  end

  test "unhandled scope only lists messages still waiting" do
    waiting = Inquiry.create!(name: "Ana", email: "ana@example.com", message: "Hola")
    answered = Inquiry.create!(name: "Beto", email: "beto@example.com", message: "Hola",
                               handled_at: Time.current)

    assert_includes Inquiry.unhandled, waiting
    assert_not_includes Inquiry.unhandled, answered
    assert answered.handled?
  end
end
