module CoursesHelper
  CURRENCY_UNITS = { "ARS" => "$", "USD" => "US$", "EUR" => "€" }.freeze

  def formatted_price(course)
    return t("courses.free") if course.free?

    number_to_currency(course.price,
      unit: CURRENCY_UNITS.fetch(course.currency, "#{course.currency} "),
      format: "%u%n",
      precision: 0)
  end

  def course_modality(course)
    t("courses.modality.#{course.modality}")
  end

  def course_status_label(course)
    t("courses.status.#{course.status}")
  end
end
