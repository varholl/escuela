require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @published = Article.create!(title: "Respirar no es relajarse", published_at: 1.day.ago)
    @draft = Article.create!(title: "Borrador sin terminar")
  end

  test "index lists published notes only" do
    get reflections_path

    assert_response :success
    assert_select "h3", text: @published.title
    assert_select "h3", text: @draft.title, count: 0
  end

  test "index shows an empty state when nothing is published in this locale" do
    Article.destroy_all

    get reflections_path

    assert_response :success
    assert_select "p", text: I18n.t("articles.sections.reflection.empty")
  end

  test "show renders a published note" do
    get reflection_path(id: @published)

    assert_response :success
    assert_select "h1", text: @published.title
  end

  test "show hides a draft from the public" do
    get reflection_path(id: @draft)

    assert_response :not_found
  end

  test "an administrator can preview a draft" do
    sign_in_as users(:owner)

    get reflection_path(id: @draft)

    assert_response :success
    assert_select "p", text: I18n.t("articles.show.draft_notice")
  end

  test "a signed-in student cannot preview a draft" do
    sign_in_as users(:student)

    get reflection_path(id: @draft)

    assert_response :not_found
  end

  test "each section lists only its own pieces" do
    note = Article.create!(title: "La alianza terapéutica", kind: :note, published_at: 1.day.ago)

    get notes_path
    assert_select "h3", text: note.title
    assert_select "h3", text: @published.title, count: 0

    get reflections_path
    assert_select "h3", text: @published.title
    assert_select "h3", text: note.title, count: 0
  end

  test "a note is read under /apuntes" do
    note = Article.create!(title: "La alianza terapéutica", kind: :note, published_at: 1.day.ago)

    get note_path(id: note)

    assert_response :success
    assert_select "h1", text: note.title
    assert_select "a[href=?]", notes_path, text: I18n.t("articles.sections.note.back")
  end

  test "a piece asked for under the other section moves to its own" do
    note = Article.create!(title: "La alianza terapéutica", kind: :note, published_at: 1.day.ago)

    get reflection_path(id: note)

    assert_redirected_to note_path(id: note)
    assert_response :moved_permanently
  end

  test "the old /notas links land on the reflections" do
    get "/notas"
    assert_redirected_to "/reflexiones"
    assert_response :moved_permanently

    get "/notas/#{@published.slug}"
    assert_redirected_to "/reflexiones/#{@published.slug}"

    get "/notas/#{@published.slug}/portada"
    assert_redirected_to "/reflexiones/#{@published.slug}/portada"
  end

  test "show suggests other published notes" do
    other = Article.create!(title: "El insomnio como mensajero", published_at: 2.days.ago)

    get reflection_path(id: @published)

    assert_select "h3", text: other.title
  end

  test "suggestions stay within the section" do
    Article.create!(title: "La alianza terapéutica", kind: :note, published_at: 2.days.ago)

    get reflection_path(id: @published)

    assert_select "h3", text: "La alianza terapéutica", count: 0
  end
end
