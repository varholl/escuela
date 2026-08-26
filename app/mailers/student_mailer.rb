# Everything the school sends to a student. All of it is triggered by something
# she did or something the owner did for her -- there is no list here, and
# nothing is sent unasked.
class StudentMailer < ApplicationMailer
  def welcome(user)
    @user = user

    mail to: user.email_address, subject: t("student_mailer.welcome.subject", site: t("site.name"))
  end

  def enrolled(enrollment)
    @enrollment = enrollment
    @course = enrollment.course
    @user = enrollment.user

    mail to: @user.email_address,
         subject: t("student_mailer.enrolled.subject", course: @course.title)
  end
end
