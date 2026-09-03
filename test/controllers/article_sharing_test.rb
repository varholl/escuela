require "test_helper"

# Passing a note on: the buttons on the page, and what the link looks like when
# it lands in someone's chat.
class ArticleSharingTest < ActionDispatch::IntegrationTest
  setup do
    @article = Article.create!(title: "Respirar no es relajarse",
                               excerpt: "Volver es otra cosa.",
                               published_at: 1.day.ago)
  end

  # Turning a cover into a social card actually runs the image through libvips.
  # The Dockerfile and CI both install it; a laptop may not, and a red suite
  # that only means "no vips here" teaches nobody anything.
  def requires_image_processor
    skip "libvips is not installed here -- brew install vips" unless ActiveStorage.variant_transformer
  end

  def attach_cover(article)
    article.cover_image.attach(
      io: File.open(Rails.root.join("app/assets/images/og-image.png")),
      filename: "portada.png", content_type: "image/png")
    article
  end

  test "a published note offers a way to pass it on" do
    get article_path(id: @article)

    assert_response :success
    assert_select "[data-controller=share]"
    assert_select "[data-share-url-value=?]", article_url(id: @article)
  end

  test "the WhatsApp link carries the title and the address" do
    get article_path(id: @article)

    href = css_select("a[href^='https://wa.me/']").first["href"]
    text = CGI.unescape(href.split("text=").last)

    assert_includes text, @article.title
    assert_includes text, article_url(id: @article)
  end

  test "the buttons that need JavaScript start hidden" do
    get article_path(id: @article)

    assert_select "button[data-share-target=copy][hidden]"
    assert_select "button[data-share-target=native][hidden]"
  end

  test "a draft is not offered for sharing" do
    draft = Article.create!(title: "Borrador sin terminar")
    sign_in_as users(:owner)

    get article_path(id: draft)

    assert_response :success
    assert_select "[data-controller=share]", count: 0
  end

  test "a note with a cover puts it forward as the preview picture" do
    attach_cover @article

    get article_path(id: @article)

    assert_select "meta[property='og:image'][content=?]", cover_article_url(id: @article)
    assert_select "meta[name='twitter:image'][content=?]", cover_article_url(id: @article)
    assert_select "meta[property='og:image:alt'][content=?]", @article.title
  end

  test "a note without a cover falls back to the school's card" do
    get article_path(id: @article)

    image = css_select("meta[property='og:image']").first["content"]
    assert_match %r{/assets/og-image-\w+\.png\z}, image
  end

  # The whole reason ArticleCoversController exists. Active Storage's own URLs
  # expire in five minutes here, and a link preview is fetched again every time
  # the link is pasted somewhere new -- days later, not minutes.
  test "the preview address is not an expiring Active Storage URL" do
    attach_cover @article

    get article_path(id: @article)
    image = css_select("meta[property='og:image']").first["content"]

    assert_no_match %r{/rails/active_storage/}, image
    assert_match %r{/notas/#{@article.slug}/portada\z}, image
  end

  test "the cover address hands over the picture" do
    requires_image_processor
    attach_cover @article

    get cover_article_path(id: @article)

    assert_response :redirect
    # Straight at the storage service, minted for this request, rather than at
    # anything the address itself has to keep alive.
    assert_match %r{/rails/active_storage/}, response.location
  end

  test "asking for the cover of a note that has none says so" do
    get cover_article_path(id: @article)

    assert_response :not_found
  end

  test "a draft's cover is not served" do
    draft = attach_cover(Article.create!(title: "Borrador sin terminar"))

    get cover_article_path(id: draft)

    assert_response :not_found
  end
end
