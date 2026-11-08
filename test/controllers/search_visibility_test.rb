require "test_helper"

class SearchVisibilityTest < ActionDispatch::IntegrationTest
  setup do
    @article = Article.create!(title: "Respirar despacio", locale: "es", body: "Texto", published_at: 1.day.ago)
    @draft = Article.create!(title: "Borrador sin salir", locale: "es", body: "Texto")
  end

  teardown do
    Rails.configuration.x.allow_indexing = false
    Rails.configuration.x.goatcounter_code = nil
  end

  test "the sitemap is not there while the site stays out of search engines" do
    Rails.configuration.x.allow_indexing = false

    get sitemap_path

    assert_response :not_found
  end

  test "the sitemap lists published pieces and leaves drafts out" do
    Rails.configuration.x.allow_indexing = true

    get sitemap_path

    assert_response :success
    assert_includes response.body, reflection_url(id: @article)
    assert_includes response.body, root_url
    assert_not_includes response.body, @draft.slug
  end

  test "robots.txt points to the sitemap once indexing is allowed" do
    Rails.configuration.x.allow_indexing = true

    get robots_path

    assert_match %r{^Sitemap: http://www.example.com/sitemap.xml$}, response.body
  end

  test "a published piece describes itself to search engines" do
    get reflection_path(id: @article)

    data = JSON.parse(css_select("script[type='application/ld+json']").first.text)
    assert_equal "Article", data["@type"]
    assert_equal "Respirar despacio", data["headline"]
  end

  test "the canonical address leaves tracking parameters out" do
    get reflection_path(id: @article, utm_source: "instagram")

    assert_select "link[rel=canonical][href=?]", reflection_url(id: @article)
  end

  test "visits are counted only once an account is configured" do
    get root_path
    assert_select "script[data-goatcounter]", count: 0

    Rails.configuration.x.goatcounter_code = "volveralalma"
    get root_path
    assert_select "script[data-goatcounter=?]", "https://volveralalma.goatcounter.com/count"
  end
end
