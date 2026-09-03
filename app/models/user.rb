class User < ApplicationRecord
  # Only ever used to confirm a change of email or password on the account
  # screen; never persisted.
  attr_accessor :current_password

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :enrollments, dependent: :destroy
  has_many :courses, through: :enrollments

  enum :role, { student: 0, admin: 1 }, default: :student, validate: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :name, with: ->(n) { n.strip }

  validates :email_address, presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, length: { maximum: 120 }
  validates :password, length: { minimum: 8 }, allow_nil: true

  # Finding or making the account behind a Google sign-in.
  #
  # Linking by email is what stops someone who signed up with a password from
  # ending up with a second, empty account when they later use the Google
  # button -- they would lose their courses without understanding why. It is
  # only safe because Google says whether it has verified the address; an
  # unverified one would let anyone claim an existing account by creating a
  # Google profile with someone else's email.
  def self.from_google(auth)
    email = google_email(auth)
    return nil if email.blank?

    user = find_google(auth, email)
    user ||= new(email_address: email, role: :student, password: SecureRandom.base58(32))

    user.provider = "google_oauth2"
    user.uid = auth.uid
    # Only fill a name in, never overwrite one she has chosen here.
    user.name = auth.info.name if user.name.blank?
    user.save!

    user
  end

  # Whether this Google identity already belongs to someone here.
  #
  # While the school is closed that is the whole difference between signing in
  # and being turned away: the button opens the door for the accounts she
  # created, not for anyone who happens to have a Google profile.
  def self.google_account?(auth)
    email = google_email(auth)
    email.present? && find_google(auth, email).present?
  end

  # The address Google is willing to vouch for, or nothing when it is not.
  def self.google_email(auth)
    return nil unless auth.info.email_verified

    auth.info.email.to_s.strip.downcase.presence
  end
  private_class_method :google_email

  def self.find_google(auth, email)
    find_by(provider: "google_oauth2", uid: auth.uid) || find_by(email_address: email)
  end
  private_class_method :find_google

  # Someone who has only ever used Google has a password nobody knows, including
  # them. They can still set one through the reset flow.
  def google?
    provider == "google_oauth2"
  end

  def enrolled_courses
    Course.joins(:enrollments).merge(enrollments.granting_access).distinct
  end

  def display_name
    name.presence || email_address.split("@").first
  end
end
