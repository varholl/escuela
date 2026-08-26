module Admin
  class LessonsController < BaseController
    before_action :set_course
    before_action :set_lesson, only: %i[ edit update destroy ]

    def index
      @lessons = @course.lessons.ordered
    end

    def new
      @lesson = @course.lessons.build(position: next_position)
    end

    def edit
    end

    def create
      @lesson = @course.lessons.build(lesson_params)

      if @lesson.save
        redirect_to admin_course_lessons_path(@course), notice: t("admin.lessons.created")
      else
        render :new, status: :unprocessable_content
      end
    end

    def update
      purge_video_if_requested

      if @lesson.update(lesson_params)
        redirect_to admin_course_lessons_path(@course), notice: t("admin.lessons.updated")
      else
        render :edit, status: :unprocessable_content
      end
    end

    def destroy
      @lesson.destroy!
      redirect_to admin_course_lessons_path(@course), notice: t("admin.lessons.destroyed"), status: :see_other
    end

    private
      def set_course
        @course = Course.find_by!(slug: params[:course_id])
      end

      def set_lesson
        @lesson = @course.lessons.find_by!(slug: params[:id])
      end

      def next_position
        (@course.lessons.maximum(:position) || 0) + 1
      end

      def lesson_params
        params.expect(lesson: [
          :title, :slug, :summary, :position, :duration_seconds,
          :video_provider, :video_reference, :published_at,
          :notes, :video
        ])
      end

      # Ticking "remove" while also choosing a new file means the new file wins:
      # purging then would throw away what was just uploaded.
      def purge_video_if_requested
        return unless params.dig(:lesson, :remove_video) == "1"
        return if lesson_params[:video].present?

        @lesson.video.purge_later
      end
  end
end
