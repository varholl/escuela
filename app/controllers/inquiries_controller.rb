class InquiriesController < ApplicationController
  rate_limit to: 5, within: 10.minutes, only: :create,
    with: -> { redirect_to new_contact_path, alert: t("inquiries.throttled") }

  def new
    @inquiry = Inquiry.new(course: requested_course)
  end

  def create
    @inquiry = Inquiry.new(inquiry_params.merge(locale: I18n.locale))

    # A bot that fills every field it finds trips the honeypot. Answer as if the
    # message went through so it has nothing to learn from the response.
    return redirect_to(new_contact_path, notice: t("inquiries.create.success")) if honeypot_tripped?

    if @inquiry.save
      notify_owner
      redirect_to new_contact_path, notice: t("inquiries.create.success")
    else
      render :new, status: :unprocessable_content
    end
  end

  private
    # The message is already saved; the email is a convenience, and it is only
    # attempted where there is somewhere to send it.
    def notify_owner
      return unless Rails.configuration.x.email_enabled

      InquiryMailer.notify(@inquiry).deliver_later
    end

    def inquiry_params
      params.expect(inquiry: [ :name, :email, :phone, :message, :course_id ])
    end

    def honeypot_tripped?
      params[:inquiry][:website].present?
    end

    def requested_course
      Course.in_locale(I18n.locale).published.find_by(slug: params[:course])
    end
end
