module Admin
  # The people with an account: who they are, what they joined, what they wrote.
  class UsersController < BaseController
    FILTERS = %w[ students admins deactivated ].freeze

    def index
      @query = params[:q].to_s.strip
      @filter = params[:filter].presence_in(FILTERS)

      @users = filtered(User.all).order(created_at: :desc)
      @users = @users.where("name LIKE :q OR email_address LIKE :q", q: "%#{User.sanitize_sql_like(@query)}%") if @query.present?
      @users = @users.includes(:enrollments)
    end

    def show
      @user = User.find(params[:id])
      @enrollments = @user.enrollments.includes(:course).order(created_at: :desc)
      # Messages are tied to an address, not an account: someone may have
      # written before signing up, or never signed up at all.
      @inquiries = Inquiry.where(email: @user.email_address).includes(:course).recent_first
      @joinable_courses = Course.where.not(status: :archived).where.not(id: @enrollments.map(&:course_id)).ordered
    end

    private
      def filtered(scope)
        case @filter
        when "students"    then scope.student.active
        when "admins"      then scope.admin
        when "deactivated" then scope.deactivated
        else scope
        end
      end
  end
end
