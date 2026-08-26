require "test_helper"

# One address for the site. www, the fly.dev name and anything else send people
# to the same place, so a shared link is always the same link and search engines
# see one site rather than three copies.
class CanonicalHostTest < ActionDispatch::IntegrationTest
  setup { Rails.configuration.x.canonical_host = "volveralalma.com.ar" }
  teardown { Rails.configuration.x.canonical_host = nil }

  test "www is sent to the bare domain" do
    get "https://www.volveralalma.com.ar/cursos"

    assert_response :moved_permanently
    assert_equal "https://volveralalma.com.ar/cursos", response.location
  end

  test "the fly.dev name is sent to the domain" do
    get "https://maflor-escuela.fly.dev/notas"

    assert_redirected_to "https://volveralalma.com.ar/notas"
  end

  test "the path and query survive the redirect" do
    get "https://www.volveralalma.com.ar/contacto/new?course=atencion-plena"

    assert_equal "https://volveralalma.com.ar/contacto/new?course=atencion-plena", response.location
  end

  test "the canonical host itself is served, not redirected" do
    get "https://volveralalma.com.ar/"

    assert_response :success
  end

  test "nothing redirects when no canonical host is configured" do
    Rails.configuration.x.canonical_host = nil

    get "https://cualquier-cosa.example.com/"

    assert_response :success
  end

  test "the health check is never redirected" do
    # Fly probes it with the machine's own address; a redirect would fail it.
    get "https://maflor-escuela.fly.dev/up"

    assert_response :success
  end
end
