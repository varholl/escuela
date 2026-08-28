require "test_helper"

class ErrorsControllerTest < ActionDispatch::IntegrationTest
  DETAILED = "action_dispatch.show_detailed_exceptions".freeze

  # The test environment serves the developer's debug page, and Rails injects
  # that choice through env_config on every request, so passing `env:` on the
  # request is not enough. These tests want what a visitor would actually see.
  setup do
    @detailed_exceptions = Rails.application.env_config[DETAILED]
    Rails.application.env_config[DETAILED] = false
  end

  teardown do
    Rails.application.env_config[DETAILED] = @detailed_exceptions
  end

  test "a missing note renders the site's own 404" do
    get "/notas/no-existe"

    assert_response :not_found
    assert_select "h1", text: I18n.t("errors.not_found.title", locale: :es)
    assert_select "a[href=?]", root_path
  end

  test "an unknown path renders the same page" do
    get "/una-ruta-que-no-existe"

    assert_response :not_found
    assert_select "h1", text: I18n.t("errors.not_found.title", locale: :es)
  end

  test "a draft note reaches the 404 rather than an exception" do
    draft = Article.create!(title: "Borrador")

    get article_path(id: draft)

    assert_response :not_found
    assert_select "h1", text: I18n.t("errors.not_found.title", locale: :es)
  end

  test "the error page still carries the site chrome" do
    get "/notas/no-existe"

    assert_select "header a[href=?]", root_path
    assert_select "footer"
  end
end
