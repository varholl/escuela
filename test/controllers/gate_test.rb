require "test_helper"

# The site closed while she is still writing it. Everything here runs with the
# doors shut, which the test environment does not do by default.
class GateTest < ActionDispatch::IntegrationTest
  setup { Rails.configuration.x.gated = true }
  teardown { Rails.configuration.x.gated = false }

  test "the root is a holding page with none of the sample content on it" do
    Course.create!(title: "Curso de muestra", status: :published)
    Article.create!(title: "Nota de muestra", published_at: 1.day.ago)

    get root_path

    assert_response :success
    assert_select "h1", text: I18n.t("gate.title")
    assert_select "body", text: /Curso de muestra/, count: 0
    assert_select "body", text: /Nota de muestra/, count: 0
  end

  # ALLOW_INDEXING on its own is not enough: there is nothing worth indexing
  # behind a site that answers every visitor with the same holding page.
  test "the holding page never invites a crawler in" do
    Rails.configuration.x.allow_indexing = true

    get root_path
    assert_select "meta[name=robots][content=?]", "noindex, nofollow"

    get robots_path
    assert_match(/^Disallow: \/$/, response.body)
  ensure
    Rails.configuration.x.allow_indexing = false
  end

  test "every public page bounces back to the holding page" do
    course = Course.create!(title: "Atención plena", status: :published)
    article = Article.create!(title: "Respirar", published_at: 1.day.ago)

    [ about_path, philosophy_path, privacy_path, terms_path,
      courses_path, course_path(id: course),
      articles_path, article_path(id: article),
      new_registration_path ].each do |path|
      get path
      assert_redirected_to root_path, "#{path} should not answer with the doors shut"
    end
  end

  test "signing up is closed, not merely hidden" do
    assert_no_difference -> { User.count } do
      post registration_path, params: {
        user: { name: "Intrusa", email_address: "intrusa@example.com",
                password: "password", password_confirmation: "password" }
      }
    end

    assert_redirected_to root_path
  end

  test "the way in and the way to write to her stay open" do
    [ new_session_path, new_password_path, new_contact_path, robots_path ].each do |path|
      get path
      assert_response :success, "#{path} has to answer with the doors shut"
    end
  end

  test "the contact form does not name the sample courses" do
    Course.create!(title: "Curso de muestra", status: :published)

    get new_contact_path

    assert_response :success
    assert_select "select#inquiry_course_id", count: 0
  end

  test "a message still reaches her from behind the gate" do
    assert_difference -> { Inquiry.count }, 1 do
      post contact_path, params: {
        inquiry: { name: "Vecina", email: "vecina@example.com", message: "¿Cuándo abrís?" }
      }
    end

    assert_redirected_to new_contact_path
  end

  test "the sign-in screen offers an invitation instead of a sign-up form" do
    get new_session_path

    assert_response :success
    assert_select "a[href=?]", new_registration_path, count: 0
    assert_select "a[href=?]", new_contact_path
  end

  test "the panel still sends her to sign in rather than to the holding page" do
    get admin_root_path

    assert_redirected_to new_session_path
  end

  test "a student coming back for their shelf gets the sign-in screen" do
    get library_path

    assert_redirected_to new_session_path
  end

  test "an error page still answers with its own status" do
    get "/no-existe"

    assert_response :not_found
  end

  test "someone she let in sees the whole site" do
    sign_in_as users(:student)

    get root_path
    assert_response :success
    assert_select "h1", text: I18n.t("home.hero.title")

    get about_path
    assert_response :success

    get courses_path
    assert_response :success
  end

  test "the doors open again with one switch" do
    Rails.configuration.x.gated = false

    get about_path

    assert_response :success
  end
end
