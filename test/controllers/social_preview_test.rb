require "test_helper"

# What someone sees when the link is pasted into WhatsApp or Instagram.
class SocialPreviewTest < ActionDispatch::IntegrationTest
  test "the home page offers an absolute preview image" do
    get root_path

    image = css_select("meta[property='og:image']").first["content"]
    assert image.start_with?("http"), "og:image must be absolute, got #{image.inspect}"
    assert image.end_with?(".png")

    assert_select "meta[property='og:image:width'][content=?]", "1200"
    assert_select "meta[property='og:image:height'][content=?]", "630"
    assert_select "meta[name='twitter:card'][content=?]", "summary_large_image"
  end

  test "a note carries its own title and description" do
    article = Article.create!(title: "Respirar no es relajarse",
                              excerpt: "Volver es otra cosa.",
                              published_at: 1.day.ago)

    get article_path(id: article)

    assert_select "meta[property='og:title'][content=?]", "Respirar no es relajarse · #{I18n.t("site.name")}"
    assert_select "meta[property='og:description'][content=?]", "Volver es otra cosa."
  end

  test "og:url reflects the page being shared" do
    get courses_path

    assert_select "meta[property='og:url'][content=?]", courses_url
  end

  test "the preview image file is actually there" do
    assert Rails.root.join("app/assets/images/og-image.png").exist?
  end
end
