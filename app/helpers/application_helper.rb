module ApplicationHelper
  # The three pillars share one ring, so each arc is a third of the same circle
  # drawn at r = 26 inside a 64-unit box.
  ARC_RADIUS = 26
  ARC_CIRCUMFERENCE = 2 * Math::PI * ARC_RADIUS
  ARC_COLORS = %w[ var(--color-iris) var(--color-rose) var(--color-gold) ].freeze

  def page_title(*parts)
    [ *parts, t("site.name") ].compact_blank.join(" · ")
  end

  def meta_description(text = nil)
    (text.presence || t("site.meta_description")).to_s.squish.truncate(160)
  end

  def arc_dasharray
    third = ARC_CIRCUMFERENCE / 3
    "#{third.round(2)} #{(ARC_CIRCUMFERENCE - third).round(2)}"
  end

  def arc_rotation(index)
    -90 + index * 120
  end

  def arc_color(index)
    ARC_COLORS[index % ARC_COLORS.size]
  end

  # Where a standing page shows up on the public site.
  def admin_page_preview_path(page)
    case page.key
    when "home" then root_path
    when "about" then about_path
    when "privacy" then privacy_path
    when "terms" then terms_path
    else philosophy_path
    end
  end

  def flash_classes(level)
    case level.to_s
    when "alert", "error" then "border-rose bg-rose/10 text-ink"
    else "border-iris bg-iris-pale text-ink"
    end
  end

  def localized_date(date, format: :long_month)
    return nil if date.blank?

    l(date.to_date, format: format)
  end
end
