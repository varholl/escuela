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
      @course = Course.new(locale: I18n.locale, currency: "ARS", kind: requested_kind)
      # Most workshops are recordings, watched whenever the student likes.
      @course.modality = :on_demand if @course.workshop?
    end

    def edit
    end

    def create
      @course = Course.new(kind: requested_kind)
      @course.assign_attributes(course_params)

      if @course.save
        redirect_to edit_admin_course_path(@course), notice: message(:created)
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      if @course.update(course_params)
        redirect_to edit_admin_course_path(@course), notice: message(:updated)
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @course.destroy!
      redirect_to admin_courses_path, notice: message(:destroyed), status: :see_other
    end

    private
      def set_course
        @course = Course.find_by!(slug: params[:id])
      end

      # Chosen once, when it is created: a course with lessons of its own makes
      # no sense as a single video, nor the other way round.
      def requested_kind
        params[:kind].presence_in(Course.kinds.keys) ||
          params.dig(:course, :kind).presence_in(Course.kinds.keys) ||
          "course"
      end

      def course_params
        permitted = params.expect(course: [
          :title, :subtitle, :summary, :locale, :status, :modality,
          :price_cents, :currency, :duration_label, :starts_on, :position,
          :published_at, :description, :cover_image,
          recording_attributes: [ :video_provider, :video_reference, :video, :remove_video ]
        ])
        # Only a workshop has a recording; a course's lessons have their own form.
        @course.workshop? ? permitted : permitted.except(:recording_attributes)
      end

      def message(key)
        t(@course.workshop? ? "admin.courses.workshop.#{key}" : "admin.courses.#{key}")
      end
  end
end
