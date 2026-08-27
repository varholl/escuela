require "test_helper"

class LessonTest < ActiveSupport::TestCase
  setup { @course = Course.create!(title: "Atención plena") }

  test "slugs only need to be unique inside their course" do
    other_course = Course.create!(title: "Habitar el cuerpo")

    first = @course.lessons.create!(title: "Primera práctica")
    second = other_course.lessons.create!(title: "Primera práctica")

    assert_equal "primera-practica", first.slug
    assert_equal "primera-practica", second.slug
  end

  test "disambiguates a repeated slug within one course" do
    @course.lessons.create!(title: "Práctica")
    duplicate = @course.lessons.create!(title: "Práctica")

    assert_equal "practica-2", duplicate.slug
  end

  test "rejects a provider the site cannot play" do
    %w[ dailymotion mux ].each do |provider|
      lesson = @course.lessons.build(title: "Clase", video_provider: provider)

      assert_not lesson.valid?, "#{provider} should not be accepted"
    end
  end

  test "formats duration as minutes and seconds" do
    assert_equal "1:30", @course.lessons.create!(title: "Corta", duration_seconds: 90).duration
    assert_equal "1:05:00", @course.lessons.create!(title: "Larga", duration_seconds: 3900).duration
    assert_nil @course.lessons.create!(title: "Sin dato").duration
  end
end
