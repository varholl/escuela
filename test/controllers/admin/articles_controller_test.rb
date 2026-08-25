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

      assert_redirected_to admin_articles_path
    end
  end
end
