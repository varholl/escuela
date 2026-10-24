require "test_helper"

# The courses page shows the newest three of each kind and offers the rest.
class CoursesOverviewTest < ActionDispatch::IntegrationTest
  def publish(count, kind:, prefix:)
    count.times.map do |i|
      travel_to (count - i).days.ago do
        Course.create!(title: "#{prefix} #{i + 1}", kind: kind, status: :published)
      end
    end
  end

  test "the overview shows the three newest courses and offers the rest" do
    oldest, *newest = publish(4, kind: :course, prefix: "Curso")

    get courses_path

    newest.each { |course| assert_select "h3", text: course.title }
    assert_select "h3", text: oldest.title, count: 0
    assert_select "a[href=?]", courses_path(ver: "cursos"), text: "Ver todos los cursos"
  end

  test "three courses or fewer need no link to the rest" do
    publish(3, kind: :course, prefix: "Curso")

    get courses_path

    assert_select "a[href=?]", courses_path(ver: "cursos"), count: 0
  end

  test "the same for workshops" do
    oldest, *newest = publish(4, kind: :workshop, prefix: "Taller")

    get courses_path

    newest.each { |workshop| assert_select "section[aria-labelledby=workshops-title] h3", text: workshop.title }
    assert_select "h3", text: oldest.title, count: 0
    assert_select "a[href=?]", courses_path(ver: "talleres"), text: "Ver todos los talleres"
  end

  test "the full list of courses has every course and no workshops" do
    courses = publish(4, kind: :course, prefix: "Curso")
    workshop = Course.create!(title: "Una charla", kind: :workshop, status: :published)

    get courses_path(ver: "cursos")

    assert_select "h1", text: "Todos los cursos"
    courses.each { |course| assert_select "h3", text: course.title }
    assert_select "h3", text: workshop.title, count: 0
    assert_select "a[href=?]", courses_path, text: "Volver a cursos y talleres"
  end

  test "the full list of workshops has every workshop and no courses" do
    workshops = publish(4, kind: :workshop, prefix: "Taller")
    course = Course.create!(title: "Un curso", status: :published)

    get courses_path(ver: "talleres")

    assert_select "h1", text: "Todos los talleres"
    workshops.each { |workshop| assert_select "h3", text: workshop.title }
    assert_select "h3", text: course.title, count: 0
  end

  test "an unknown list falls back to the overview" do
    get courses_path(ver: "otra-cosa")

    assert_response :success
    assert_select "h1", text: "Cursos y encuentros"
  end
end
