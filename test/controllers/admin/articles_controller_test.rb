require "test_helper"

module Admin
  class ArticlesControllerTest < ActionDispatch::IntegrationTest
    setup do
      sign_in_as users(:owner)
      @article = Article.create!(title: "Respirar no es relajarse", published_at: 1.day.ago)
    end

    test "index lists drafts alongside published notes" do
      draft = Article.create!(title: "Borrador")

      get admin_articles_path

      assert_response :success
      assert_select "a", text: @article.title
      assert_select "a", text: draft.title
    end

    test "reflections and notes are listed apart" do
      note = Article.create!(title: "La alianza terapéutica", kind: :note)

      get admin_articles_path(kind: "note")
      assert_select "a", text: note.title
      assert_select "a", text: @article.title, count: 0

      get admin_articles_path
      assert_select "a", text: @article.title
      assert_select "a", text: note.title, count: 0
    end

    test "a new piece belongs to the section it was started from" do
      get new_admin_article_path(kind: "note")

      assert_select "input[type=hidden][name=?][value=?]", "article[kind]", "note"
      assert_select "select[name=?]", "article[kind]", count: 0
    end

    test "the address is shown, not edited" do
      get new_admin_article_path
      assert_select "[name=?]", "article[slug]", count: 0

      get edit_admin_article_path(@article)
      assert_select "[name=?]", "article[slug]", count: 0
      assert_select "a[href=?]", reflection_url(id: @article)
      assert_select "button[data-action=?]", "share#copy"
    end

    test "the address cannot be changed by hand" do
      patch admin_article_path(@article), params: { article: { slug: "otra-cosa" } }

      assert_equal "respirar-no-es-relajarse", @article.reload.slug
    end

    test "editing a piece cannot move it to the other section" do
      patch admin_article_path(@article), params: { article: { kind: "note" } }

      assert @article.reload.reflection?

      get edit_admin_article_path(@article)
      assert_select "[name=?]", "article[kind]", count: 0
    end

    test "create stores a note in the section chosen" do
      post admin_articles_path, params: { article: { title: "La alianza terapéutica", kind: "note" } }

      assert Article.last.note?
    end

    test "create stores a note with its body" do
      assert_difference -> { Article.count }, 1 do
        post admin_articles_path, params: {
          article: { title: "El insomnio como mensajero", body: "<p>Un aviso.</p>" }
        }
      end

      article = Article.last
      assert_redirected_to edit_admin_article_path(article)
      assert_equal "el-insomnio-como-mensajero", article.slug
      assert_includes article.body.to_s, "Un aviso."
      assert article.drafted?
    end

    test "create re-renders the form without a title" do
      assert_no_difference -> { Article.count } do
        post admin_articles_path, params: { article: { title: "" } }
      end

      assert_response :unprocessable_content
    end

    test "update saves the changes" do
      patch admin_article_path(@article), params: { article: { title: "Otro título" } }

      assert_redirected_to edit_admin_article_path(@article)
      assert_equal "Otro título", @article.reload.title
    end

    test "publishing from the index sets the date" do
      draft = Article.create!(title: "Borrador")

      patch admin_article_path(draft), params: { article: { published_at: Time.current.iso8601 } }

      assert draft.reload.published?
    end

    test "unpublishing from the index clears the date" do
      patch admin_article_path(@article), params: { article: { published_at: "" } }

      assert @article.reload.drafted?
    end

    test "destroy removes the note" do
      assert_difference -> { Article.count }, -1 do
        delete admin_article_path(@article)
      end

      assert_redirected_to admin_articles_path(kind: "reflection")
    end

    test "a piece carries internal tags, offering the ones already in use" do
      Tag.create!(name: "insomnio")

      get edit_admin_article_path(@article)

      assert_select "input[name=?]", "article[tag_list]"
      assert_select "button[data-tag-list-name-param=insomnio]"

      patch admin_article_path(@article), params: { article: { tag_list: "Insomnio, duelo" } }

      assert_equal %w[ duelo insomnio ], @article.reload.tags.map(&:name)
    end

    test "however many tags there are, only ten are on screen at first" do
      15.times { |i| Tag.create!(name: "tema-#{i}") }

      get edit_admin_article_path(@article)

      assert_select "button[data-tag-list-target=option]", 15
      assert_select "button[data-tag-list-target=option]:not([hidden])", 10
    end
  end
end
