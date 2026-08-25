require "test_helper"

class CourseTest < ActiveSupport::TestCase
  test "is a draft until published" do
    course = Course.create!(title: "Atención plena")

    assert course.draft?
    assert_not_includes Course.published, course

    course.published!
    assert_includes Course.published, course
  end

  test "treats a missing or zero price as free" do
    assert Course.new(title: "Abierto").free?
    assert Course.new(title: "Abierto", price_cents: 0).free?
    assert_not Course.new(title: "Pago", price_cents: 1).free?
  end

  test "converts cents to a decimal amount" do
    course = Course.create!(title: "Ciclo", price_cents: 12_000_00)

    assert_in_delta 12_000.0, course.price, 0.001
  end

  test "rejects a negative price" do
    assert_not Course.new(title: "Ciclo", price_cents: -1).valid?
  end

  test "ordered sorts by position first" do
    second = Course.create!(title: "Segundo", position: 2)
    first = Course.create!(title: "Primero", position: 1)

    assert_equal [ first, second ], Course.ordered.to_a
  end

  test "upcoming? looks at the start date" do
    assert Course.new(title: "Pronto", starts_on: Date.current).upcoming?
    assert_not Course.new(title: "Pasado", starts_on: Date.yesterday).upcoming?
    assert_not Course.new(title: "Sin fecha").upcoming?
  end

  test "destroying a course keeps the messages that referenced it" do
    course = Course.create!(title: "Ciclo")
    inquiry = Inquiry.create!(name: "Ana", email: "ana@example.com", message: "Hola", course: course)

    course.destroy!

    assert_nil inquiry.reload.course_id
  end
end
