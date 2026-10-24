class User < ApplicationRecord
  # Only ever used to confirm a change of email or password on the account
  # screen; never persisted.
  attr_accessor :current_password

  has_secure_password
  has_many :sessions, dependent: :destroy
  has_many :enrollments, dependent: :destroy
  has_many :courses, through: :enrollments
  has_many :readings, dependent: :delete_all

  enum :role, { student: 0, admin: 1 }, default: :student, validate: true

  normalizes :email_address, with: ->(e) { e.strip.downcase }
  normalizes :name, with: ->(n) { n.strip }

  validates :email_address, presence: true,
    uniqueness: { case_sensitive: false },
    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, length: { maximum: 120 }
  validates :password, length: { minimum: 8 }, allow_nil: true

  scope :active, -> { where(deactivated_at: nil) }
  scope :deactivated, -> { where.not(deactivated_at: nil) }

  # Taking back the permission takes back what it allowed: what they read is
  # forgotten the moment they untick it, not left behind unused.
  # Same transaction as the change itself, so one can never land without the other.
  after_update -> { readings.delete_all }, if: -> { saved_change_to_reading_history_consent_at? && !remembers_reading? }

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

  # Turning someone away shuts every way in -- password, Google, a session
  # already open, a reset link -- but keeps their record, so they can be let
  # back in with their courses intact. An administrator cannot be turned away
  # from the panel: with one owner, that would lock the school.
  # Two permissions, both off until given. Each is kept as the moment it was
  # given, and the form sees it as a tick box: ticking an already-given one
  # keeps the original date.
  def remembers_reading?
    reading_history_consent_at.present?
  end
  alias_method :remember_reading, :remembers_reading?

  def remember_reading=(value)
    self.reading_history_consent_at = consent_from(value, reading_history_consent_at)
  end

  def wants_news?
    news_consent_at.present?
  end
  alias_method :wants_news, :wants_news?

  def wants_news=(value)
    self.news_consent_at = consent_from(value, news_consent_at)
  end

  def deactivated?
    deactivated_at.present?
  end

  def deactivatable?
    student? && !deactivated?
  end

  def deactivate!
    raise ArgumentError, "an administrator cannot be deactivated" if admin?

    transaction do
      update!(deactivated_at: Time.current)
      sessions.destroy_all
    end
  end

  def reactivate!
    update!(deactivated_at: nil)
  end

  private
    def consent_from(value, given_at)
      ActiveModel::Type::Boolean.new.cast(value) ? (given_at || Time.current) : nil
    end
end
