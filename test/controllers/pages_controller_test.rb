require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "home renders in Spanish at the bare path" do
    get root_path

    assert_response :success
    assert_select "html[lang=es]"
    assert_select "h1", text: I18n.t("home.hero.title", locale: :es)
  end

  test "home renders in English under the /en prefix" do
    get root_path(locale: "en")

    assert_response :success
    assert_select "html[lang=en]"
    assert_select "h1", text: I18n.t("home.hero.title", locale: :en)
  end

  test "links stay unprefixed in the default locale" do
    get root_path

    assert_select "a[href=?]", courses_path
    assert_select "a[href='/cursos']"
  end

  test "links carry the locale prefix in English" do
    get root_path(locale: "en")

    assert_select "a[href='/en/cursos']"
  end

  test "an unsupported locale falls back to Spanish rather than 404ing" do
    get "/notas?locale=fr"

    assert_response :success
    assert_select "html[lang=es]"
  end

  test "home only lists content in the current locale" do
    spanish = Article.create!(title: "Nota en español", locale: "es", published_at: 1.day.ago)
    english = Article.create!(title: "Note in English", locale: "en", published_at: 1.day.ago)

    get root_path
    assert_select "h3", text: spanish.title
    assert_select "h3", text: english.title, count: 0
  end

  test "hreflang links are absolute, or search engines ignore them" do
    get root_path

    css_select("link[rel=alternate]").each do |link|
      assert link["href"].start_with?("http"), "hreflang href must be absolute: #{link["href"]}"
    end
    assert_select "link[rel=alternate][hreflang=es]"
    assert_select "link[rel=alternate][hreflang=en]"
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
