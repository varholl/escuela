require "test_helper"

# Turning a Google profile into an account. The linking rule is the delicate
# part: get it wrong and someone loses access to courses they paid for.
class GoogleSignInTest < ActiveSupport::TestCase
  def auth(email:, uid: "google-123", name: "Ana Google", verified: true)
    OmniAuth::AuthHash.new(
      provider: "google_oauth2", uid: uid,
      info: { email: email, email_verified: verified, name: name }
    )
  end

  test "a first-time visitor gets a student account" do
    user = User.from_google(auth(email: "nueva@example.com"))

    assert user.persisted?
    assert user.student?, "signing in with Google must never mint an admin"
    assert_equal "google_oauth2", user.provider
    assert_equal "google-123", user.uid
  end

  test "signing in again returns the same account, not a second one" do
    first = User.from_google(auth(email: "nueva@example.com"))

    assert_no_difference -> { User.count } do
      assert_equal first, User.from_google(auth(email: "nueva@example.com"))
    end
  end

  test "an existing password account is linked, not duplicated" do
    existing = users(:student)

    assert_no_difference -> { User.count } do
      linked = User.from_google(auth(email: existing.email_address))
      assert_equal existing, linked
    end

    assert_equal "google_oauth2", existing.reload.provider
  end

  test "linking keeps the courses the account already had" do
    course = Course.create!(title: "Atención plena", status: :published)
    course.join!(users(:student))

    User.from_google(auth(email: users(:student).email_address))

    assert course.enrolled?(users(:student).reload)
  end

  test "an unverified address is refused" do
    assert_no_difference -> { User.count } do
      assert_nil User.from_google(auth(email: "cualquiera@example.com", verified: false))
    end
  end

  test "an unverified address cannot claim somebody else's account" do
    assert_nil User.from_google(auth(email: users(:owner).email_address, verified: false))
    assert_nil users(:owner).reload.provider
  end

  test "the email is normalised, so a capitalised one links too" do
    existing = users(:student)

    linked = User.from_google(auth(email: existing.email_address.upcase))

    assert_equal existing, linked
  end

  test "a name already chosen here is not overwritten by Google's" do
    users(:student).update!(name: "Como me llamo yo")

    User.from_google(auth(email: users(:student).email_address, name: "Google Name"))

    assert_equal "Como me llamo yo", users(:student).reload.name
  end

  test "a blank name is filled in from Google" do
    users(:student).update!(name: nil)

    User.from_google(auth(email: users(:student).email_address, name: "Ana Google"))

    assert_equal "Ana Google", users(:student).reload.name
  end

  test "an account made through Google can still set a password later" do
    user = User.from_google(auth(email: "nueva@example.com"))

    assert user.google?
    assert user.update(password: "una-clave-elegida", password_confirmation: "una-clave-elegida")
    assert User.authenticate_by(email_address: "nueva@example.com", password: "una-clave-elegida")
  end
end
