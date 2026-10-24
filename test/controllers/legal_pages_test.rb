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

  # The text is maintained in db/legal_content.rb and must keep describing
  # what the code does; these are the parts most likely to drift.
  test "the privacy text names what is remembered, and that it is optional" do
    require Rails.root.join("db/legal_content")
    privacy = LEGAL_CONTENT.fetch([ "privacy", "es" ])[:body]

    assert_includes privacy, "Recordar qué temas leo"
    assert_includes privacy, "se borra en el momento"
    assert_includes privacy, "recibir novedades"
    assert_includes privacy, "último ingreso"
  end

  test "she can edit them from the panel like any other page" do
    sign_in_as users(:owner)
    page = Page.create!(key: "terms", locale: "es")

    get edit_admin_page_path(page)

    assert_response :success
  end
end
