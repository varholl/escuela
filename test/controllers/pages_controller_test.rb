require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "home renders in Spanish at the bare path" do
    get root_path

    assert_response :success
    assert_select "html[lang=es]"
    assert_select "h1", text: I18n.t("home.hero.title", locale: :es)
  end

  test "home shows the latest reflections but not the notes" do
    reflection = Article.create!(title: "Respirar no es relajarse", published_at: 1.day.ago)
    note = Article.create!(title: "La alianza terapéutica", kind: :note, published_at: 1.day.ago)

    get root_path

    assert_select "h3", text: reflection.title
    assert_select "h3", text: note.title, count: 0
  end

  test "the /en prefix is gone, not silently translated" do
    get "/en"
    assert_response :not_found

    get "/en/reflexiones"
    assert_response :not_found
  end

  test "links stay unprefixed in the default locale" do
    get root_path

    assert_select "a[href=?]", courses_path
    assert_select "a[href='/cursos']"
  end

  test "an unsupported locale falls back to Spanish rather than 404ing" do
    get "/reflexiones?locale=fr"

    assert_response :success
    assert_select "html[lang=es]"
  end

  test "about renders the stored page" do
    page = Page.create!(key: "about", locale: "es", title: "Sobre mí", subtitle: "Psiquiatra")
    page.body = "<p>Mi recorrido.</p>"
    page.save!

    get about_path

    assert_response :success
    assert_select "h1", text: "Sobre mí"
    assert_select ".prose-note", text: /Mi recorrido/
  end

  test "about still renders before any content has been written" do
    get about_path

    assert_response :success
    assert_select "h1", text: I18n.t("pages.about.default_title")
  end

  test "philosophy renders" do
    get philosophy_path
    assert_response :success
  end
end
