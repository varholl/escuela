require "test_helper"

# Google will not publish an OAuth consent screen without these, and they must
# be reachable without signing in.
class LegalPagesTest < ActionDispatch::IntegrationTest
  test "both pages are public in Spanish" do
    { privacy_path => "privacy", terms_path => "terms" }.each do |path, key|
      get path
      assert_response :success, "#{path} must be reachable by anyone"
      assert_select "h1", text: I18n.t("pages.#{key}.default_title")
    end
  end

  test "both pages are public in English" do
    [ privacy_path(locale: "en"), terms_path(locale: "en") ].each do |path|
      get path
      assert_response :success
    end
  end

  test "the footer links to both from every page" do
    get root_path

    assert_select "footer a[href=?]", privacy_path
    assert_select "footer a[href=?]", terms_path
  end

  test "they render whatever has been written into them" do
    page = Page.create!(key: "privacy", locale: "es", title: "Privacidad")
    page.body = "<p>Guardamos tu correo y nada más.</p>"
    page.save!

    get privacy_path

    assert_select ".prose-note", text: /Guardamos tu correo/
  end

  test "an English visitor falls back rather than seeing an empty page" do
    Page.create!(key: "terms", locale: "es", title: "Términos").tap do |p|
      p.body = "<p>Condiciones.</p>"
      p.save!
    end

    get terms_path(locale: "en")

    assert_response :success
    assert_select ".prose-note", text: /Condiciones/
  end

  test "she can edit them from the panel like any other page" do
    sign_in_as users(:owner)
    page = Page.create!(key: "terms", locale: "es")

    get edit_admin_page_path(page)

    assert_response :success
  end
end
