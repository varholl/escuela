require "test_helper"

class TaggableTest < ActiveSupport::TestCase
  test "a comma list becomes one tag per idea, whatever the spelling" do
    article = Article.create!(title: "Respirar", tag_list: "Ansiedad, respiración ,  ansiedad,")

    assert_equal %w[ ansiedad respiración ], article.reload.tags.map(&:name)
    assert_equal "ansiedad, respiración", article.tag_list
  end

  test "editing the list replaces it, and reuses tags that already exist" do
    article = Article.create!(title: "Respirar", tag_list: "ansiedad, respiración")
    course = Course.create!(title: "Curso", tag_list: "Insomnio")

    article.update!(tag_list: "respiración, insomnio")

    assert_equal %w[ insomnio respiración ], article.reload.tags.map(&:name)
    assert_equal 3, Tag.count
    assert_equal course.tags.first, Tag.find_by(name: "insomnio")
  end

  test "a record that fails to save leaves no tags behind" do
    article = Article.new(title: "", tag_list: "huérfano")

    assert_not article.save
    assert_not Tag.exists?(name: "huérfano")
  end

  test "saving without touching the list keeps the tags" do
    article = Article.create!(title: "Respirar", tag_list: "ansiedad")

    Article.find(article.id).update!(title: "Respirar mejor")

    assert_equal %w[ ansiedad ], article.reload.tags.map(&:name)
  end
end
