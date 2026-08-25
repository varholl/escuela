require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  test "derives a slug from the title" do
    article = Article.create!(title: "Respirar no es relajarse")

    assert_equal "respirar-no-es-relajarse", article.slug
    assert_equal "respirar-no-es-relajarse", article.to_param
  end

  test "keeps the slug when the title is edited so shared links survive" do
    article = Article.create!(title: "Primer título")
    article.update!(title: "Otro título completamente distinto")

    assert_equal "primer-titulo", article.reload.slug
  end

  test "disambiguates a slug that is already taken" do
    Article.create!(title: "Meditar")
    duplicate = Article.create!(title: "Meditar")

    assert_equal "meditar-2", duplicate.slug
  end

  test "accepts a slug written by hand" do
    article = Article.create!(title: "Respirar", slug: "como-respirar")

    assert_equal "como-respirar", article.slug
  end

  test "rejects a slug that is not url safe" do
    article = Article.new(title: "Respirar", slug: "Con Espacios")

    assert_not article.valid?
    assert_includes article.errors.attribute_names, :slug
  end

  test "published scope excludes drafts and future dates" do
    live = Article.create!(title: "Publicada", published_at: 1.day.ago)
    draft = Article.create!(title: "Borrador")
    scheduled = Article.create!(title: "Programada", published_at: 1.day.from_now)

    assert_includes Article.published, live
    assert_not_includes Article.published, draft
    assert_not_includes Article.published, scheduled

    assert live.published?
    assert draft.drafted?
    assert scheduled.scheduled?
  end

  test "in_locale keeps the languages apart" do
    spanish = Article.create!(title: "Respirar", locale: "es")
    english = Article.create!(title: "Breathing", locale: "en")

    assert_includes Article.in_locale(:es), spanish
    assert_not_includes Article.in_locale(:es), english
  end

  test "rejects a locale the site does not serve" do
    assert_not Article.new(title: "Respirar", locale: "fr").valid?
  end

  test "reading time is never less than a minute" do
    article = Article.create!(title: "Breve")
    article.body = "<p>Dos palabras</p>"
    article.save!

    assert_equal 1, article.reading_time_minutes
  end

  test "summary falls back to the body when there is no excerpt" do
    article = Article.create!(title: "Sin copete")
    article.body = "<p>El cuerpo registra antes que la mente.</p>"
    article.save!

    assert_equal "El cuerpo registra antes que la mente.", article.summary
  end
end
