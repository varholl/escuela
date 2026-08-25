require "test_helper"

# Who may see what. Every other screen leans on these, so they are pinned down
# here rather than only through the controllers.
class CourseAccessTest < ActiveSupport::TestCase
  setup do
    @course = Course.create!(title: "Atención plena", status: :published)
    @student = users(:student)
    @admin = users(:owner)
  end

  test "nobody is enrolled by default" do
    assert_not @course.enrolled?(@student)
    assert_not @course.enrolled?(nil)
  end

  test "a pending enrollment does not count as enrolled" do
    @course.enrollments.create!(user: @student, status: :pending)

    assert_not @course.enrolled?(@student)
  end

  test "an active enrollment counts" do
    @course.enrollments.create!(user: @student, status: :active)

    assert @course.enrolled?(@student)
  end

  test "an expired enrollment stops counting" do
    @course.enrollments.create!(user: @student, status: :active, expires_at: 1.hour.ago)

    assert_not @course.enrolled?(@student)
  end

  test "a free published course can be joined by a signed-in visitor" do
    assert @course.joinable_by?(@student)
  end

  test "a course with a price cannot be self-joined" do
    @course.update!(price_cents: 10_000_00)

    assert_not @course.joinable_by?(@student)
  end

  test "an unpublished course cannot be joined" do
    @course.draft!

    assert_not @course.joinable_by?(@student)
  end

  test "someone already enrolled is not offered it again" do
    @course.enrollments.create!(user: @student, status: :active)

    assert_not @course.joinable_by?(@student)
  end

  test "a visitor who is not signed in cannot join" do
    assert_not @course.joinable_by?(nil)
  end
end

class LessonAccessTest < ActiveSupport::TestCase
  setup do
    @course = Course.create!(title: "Atención plena", status: :published)
    @lesson = @course.lessons.create!(title: "Primera práctica", published_at: 1.day.ago)
    @student = users(:student)
    @admin = users(:owner)
  end

  test "a stranger cannot open a lesson" do
    assert_not @lesson.viewable_by?(nil)
    assert_not @lesson.viewable_by?(@student)
  end

  test "an enrolled student can" do
    @course.enrollments.create!(user: @student, status: :active)

    assert @lesson.viewable_by?(@student)
  end

  test "an open session is visible to anyone" do
    @lesson.update!(free_preview: true)

    assert @lesson.viewable_by?(nil)
    assert @lesson.viewable_by?(@student)
  end

  test "an unpublished lesson stays closed even to an enrolled student" do
    @course.enrollments.create!(user: @student, status: :active)
    @lesson.update!(published_at: nil)

    assert_not @lesson.viewable_by?(@student)
  end

  test "an unpublished open session is still closed to the public" do
    @lesson.update!(free_preview: true, published_at: nil)

    assert_not @lesson.viewable_by?(nil)
  end

  test "an administrator can proof anything" do
    @lesson.update!(published_at: nil)

    assert @lesson.viewable_by?(@admin)
  end

  test "enrolled_courses lists only what actually grants access" do
    @course.enrollments.create!(user: @student, status: :active)
    expired = Course.create!(title: "Vencido", status: :published)
    expired.enrollments.create!(user: @student, status: :active, expires_at: 1.hour.ago)

    assert_includes @student.enrolled_courses, @course
    assert_not_includes @student.enrolled_courses, expired
  end
end
