require "test_helper"

class CoursesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @published = Course.create!(title: "Fundamentos de atención plena", status: :published)
    @draft = Course.create!(title: "Curso sin publicar")
  end

  test "index lists published courses only" do
    get courses_path

    assert_response :success
    assert_select "h3", text: @published.title
    assert_select "h3", text: @draft.title, count: 0
  end

  test "show renders a published course" do
    get course_path(id: @published)

    assert_response :success
    assert_select "h1", text: @published.title
  end

  test "show hides an unpublished course from the public" do
    get course_path(id: @draft)

    assert_response :not_found
  end

  test "an administrator can preview an unpublished course" do
    sign_in_as users(:owner)

    get course_path(id: @draft)

    assert_response :success
  end

  test "an archived course stays hidden even from an administrator" do
    archived = Course.create!(title: "Archivado", status: :archived)
    sign_in_as users(:owner)

    get course_path(id: archived)

    assert_response :not_found
  end

  test "show lists published lessons and hides drafts" do
    live = @published.lessons.create!(title: "Primera práctica", position: 1, published_at: 1.day.ago)
    draft = @published.lessons.create!(title: "Clase sin publicar", position: 2)

    get course_path(id: @published)

    assert_select "li", text: /#{live.title}/
    assert_select "li", text: /#{draft.title}/, count: 0
  end

  test "a paid course sends the reader to the contact form, carrying the course" do
    @published.update!(price_cents: 10_000_00)

    get course_path(id: @published)

    assert_select "a[href=?]", new_contact_path(course: @published.slug)
  end

  test "a free course offers to be joined instead of asking for an enquiry" do
    get course_path(id: @published)

    assert_select "a[href=?]", new_registration_path(course: @published.slug)
    assert_select "a[href=?]", new_contact_path(course: @published.slug), count: 0
  end
end
