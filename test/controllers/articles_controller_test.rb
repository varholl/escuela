require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @published = Article.create!(title: "Respirar no es relajarse", published_at: 1.day.ago)
    @draft = Article.create!(title: "Borrador sin terminar")
  end

  test "index lists published notes only" do
    get articles_path

    assert_response :success
    assert_select "h3", text: @published.title
    assert_select "h3", text: @draft.title, count: 0
  end

  test "index shows an empty state when nothing is published in this locale" do
    Article.destroy_all

    get articles_path

    assert_response :success
    assert_select "p", text: I18n.t("articles.index.empty")
  end

  test "show renders a published note" do
    get article_path(id: @published)

    assert_response :success
    assert_select "h1", text: @published.title
  end

  test "show hides a draft from the public" do
    get article_path(id: @draft)

    assert_response :not_found
  end

  test "an administrator can preview a draft" do
    sign_in_as users(:owner)

    get article_path(id: @draft)

    assert_response :success
    assert_select "p", text: I18n.t("articles.show.draft_notice")
  end

  test "a signed-in student cannot preview a draft" do
    sign_in_as users(:student)

    get article_path(id: @draft)

    assert_response :not_found
  end

  test "show suggests other published notes" do
    other = Article.create!(title: "El insomnio como mensajero", published_at: 2.days.ago)

    get article_path(id: @published)

    assert_select "h3", text: other.title
  end
end
