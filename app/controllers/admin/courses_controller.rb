module Admin
  class CoursesController < BaseController
    before_action :set_course, only: %i[ show edit update destroy ]

    def index
      @courses = Course.ordered
    end

    def show
      redirect_to edit_admin_course_path(@course)
    end

    def new
      @course = Course.new(locale: I18n.locale, currency: "ARS")
    end

    def edit
    end

    def create
      @course = Course.new(course_params)

      if @course.save
        redirect_to edit_admin_course_path(@course), notice: t("admin.courses.created")
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @course.update(course_params)
        redirect_to edit_admin_course_path(@course), notice: t("admin.courses.updated")
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @course.destroy!
      redirect_to admin_courses_path, notice: t("admin.courses.destroyed"), status: :see_other
    end

    private
      def set_course
        @course = Course.find_by!(slug: params[:id])
      end

      def course_params
        params.expect(course: [
          :title, :slug, :subtitle, :summary, :locale, :status, :modality,
          :price_cents, :currency, :duration_label, :starts_on, :position,
          :published_at, :description, :cover_image
        ])
      end
  end
end
