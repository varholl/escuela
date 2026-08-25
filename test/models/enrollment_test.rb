require "test_helper"

class EnrollmentTest < ActiveSupport::TestCase
  setup do
    @course = Course.create!(title: "Atención plena")
    @user = users(:student)
  end

  test "a student can only be enrolled once per course" do
    @course.enrollments.create!(user: @user)
    duplicate = @course.enrollments.build(user: @user)

    assert_not duplicate.valid?
  end

  test "only an active, unexpired enrollment grants access" do
    enrollment = @course.enrollments.create!(user: @user)
    assert_not enrollment.grants_access?

    enrollment.update!(status: :active)
    assert enrollment.grants_access?

    enrollment.update!(expires_at: 1.day.ago)
    assert_not enrollment.grants_access?
  end

  test "granting_access scope matches grants_access?" do
    open_ended = @course.enrollments.create!(user: @user, status: :active)
    expired = @course.enrollments.create!(user: users(:owner), status: :active, expires_at: 1.day.ago)

    assert_includes Enrollment.granting_access, open_ended
    assert_not_includes Enrollment.granting_access, expired
  end

  test "rejects an unknown source" do
    assert_not @course.enrollments.build(user: @user, source: "smoke signal").valid?
  end
end
