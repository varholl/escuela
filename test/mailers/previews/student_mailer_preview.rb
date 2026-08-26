# Visible at /rails/mailers/student_mailer in development.
class StudentMailerPreview < ActionMailer::Preview
  def welcome
    StudentMailer.welcome(User.new(name: "Ana", email_address: "ana@example.com"))
  end

  def enrolled
    course = Course.published.first || Course.new(title: "Atención plena", slug: "atencion-plena", locale: "es")
    StudentMailer.enrolled(Enrollment.new(course: course, user: User.new(name: "Ana", email_address: "ana@example.com")))
  end
end
