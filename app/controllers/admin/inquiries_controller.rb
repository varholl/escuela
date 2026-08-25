module Admin
  class InquiriesController < BaseController
    before_action :set_inquiry, only: %i[ show destroy ]

    def index
      @inquiries = Inquiry.includes(:course).recent_first
      @unhandled_count = Inquiry.unhandled.count
    end

    def show
    end

    def destroy
      @inquiry.destroy!
      redirect_to admin_inquiries_path, notice: t("admin.inquiries.destroyed"), status: :see_other
    end

    private
      def set_inquiry
        @inquiry = Inquiry.find(params[:id])
      end
  end
end
