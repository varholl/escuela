require "test_helper"

module Admin
  class CoursesControllerTest < ActionDispatch::IntegrationTest
    setup do
      sign_in_as users(:owner)
      @course = Course.create!(title: "Fundamentos de atención plena")
    end

    test "the address is shown once the course exists, not edited" do
      get new_admin_course_path
      assert_select "[name=?]", "course[slug]", count: 0
      assert_select "button[data-action=?]", "share#copy", count: 0

      get edit_admin_course_path(@course)
      assert_select "[name=?]", "course[slug]", count: 0
      assert_select "a[href=?]", course_url(id: @course)
      assert_select "button[data-action=?]", "share#copy"
    end

    test "a workshop shows its address the same way" do
      workshop = Course.create!(title: "Charla sobre el insomnio", kind: :workshop)

      get new_admin_course_path(kind: "workshop")
      assert_select "[name=?]", "course[slug]", count: 0

      get edit_admin_course_path(workshop)
      assert_select "a[href=?]", course_url(id: workshop)
    end

    test "the address cannot be changed by hand" do
      patch admin_course_path(@course), params: { course: { title: @course.title, slug: "otra-cosa" } }

      assert_equal "fundamentos-de-atencion-plena", @course.reload.slug
    end
  end
end
