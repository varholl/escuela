require "test_helper"

# The institutional video is public: it is the school introducing itself. But it
# still lives in a private bucket, so it goes out through a signed link.
class PageVideosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @page = Page.create!(key: "home", locale: "es")
    @page.feature_video.attach(
      io: StringIO.new("video"), filename: "institucional.mp4", content_type: "video/mp4"
    )
  end

  test "anyone can fetch it, signed in or not" do
    get page_video_path(id: "home")

    assert_response :redirect
    assert_match "institucional.mp4", response.location
  end

  test "a page with no video says there is nothing there" do
    @page.feature_video.purge

    get page_video_path(id: "home")

    assert_response :not_found
  end

  test "a key that is not a page is not routable" do
    get "/video/cualquier-cosa"

    assert_response :not_found
  end

  test "the home page shows the video once one is uploaded" do
    get root_path

    assert_select "video[src=?]", page_video_path(id: "home")
    # A large file must not start downloading before someone asks for it.
    assert_select "video[preload=none]"
  end

  test "the home page renders fine with no video at all" do
    @page.feature_video.purge

    get root_path

    assert_response :success
    assert_select "video", count: 0
  end

  test "the section heading falls back to the site copy when the page is blank" do
    get root_path

    assert_select "h2", text: I18n.t("home.approach.title")
  end

  test "a heading written in the panel wins over the default" do
    @page.update!(title: "Mirá quién soy", subtitle: "Dos minutos y medio.")

    get root_path

    assert_select "h2", text: "Mirá quién soy"
    assert_select "p", text: "Dos minutos y medio."
  end
end
