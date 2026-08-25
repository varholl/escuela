require "test_helper"

class RobotsControllerTest < ActionDispatch::IntegrationTest
  teardown { Rails.configuration.x.allow_indexing = false }

  test "keeps every crawler out while the copy is still sample text" do
    Rails.configuration.x.allow_indexing = false

    get robots_path

    assert_response :success
    assert_equal "text/plain", response.media_type
    assert_match "Disallow: /", response.body
  end

  test "opens the site up once indexing is allowed, minus the back office" do
    Rails.configuration.x.allow_indexing = true

    get robots_path

    assert_match "Disallow: /admin", response.body
    assert_no_match(/^Disallow: \/$/, response.body)
  end

  test "public pages carry a noindex tag until indexing is allowed" do
    Rails.configuration.x.allow_indexing = false

    get root_path

    assert_select "meta[name=robots][content=?]", "noindex, nofollow"
  end

  test "the noindex tag disappears once indexing is allowed" do
    Rails.configuration.x.allow_indexing = true

    get root_path

    assert_select "meta[name=robots]", count: 0
  end
end
