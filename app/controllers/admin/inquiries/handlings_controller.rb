module Admin
  module Inquiries
    # Marking a message as answered is its own resource so the button is a plain
    # POST/DELETE pair rather than an ad-hoc member action.
    class HandlingsController < BaseController
      before_action :set_inquiry

      def create
        @inquiry.update!(handled_at: Time.current)
        redirect_back_to_inquiries notice: t("admin.inquiries.marked_handled")
      end

      def destroy
        @inquiry.update!(handled_at: nil)
        redirect_back_to_inquiries notice: t("admin.inquiries.marked_unhandled")
      end

      private
        def set_inquiry
          @inquiry = Inquiry.find(params[:inquiry_id])
        end

        def redirect_back_to_inquiries(notice:)
          redirect_back fallback_location: admin_inquiries_path, notice: notice, status: :see_other
        end
    end
  end
end
