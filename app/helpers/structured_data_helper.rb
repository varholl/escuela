# What search engines read about the school, in schema.org terms: who she is,
# what the school is, and what each note and course is. Google uses it to draw
# a richer result and to tie the site to her accounts elsewhere.
module StructuredDataHelper
  OWNER_NAME = "María Florencia Di Iorio".freeze

  # Rails escapes <, > and & inside to_json, so text she writes cannot close
  # the script tag early.
  def structured_data(data)
    tag.script(data.to_json.html_safe, type: "application/ld+json")
  end

  def school_structured_data
    {
      "@context" => "https://schema.org",
      "@graph" => [
        {
          "@type" => "WebSite", "@id" => "#{root_url}#website",
          "url" => root_url, "name" => t("site.name"),
          "inLanguage" => I18n.locale.to_s,
          "publisher" => { "@id" => "#{root_url}#school" }
        },
        {
          "@type" => "EducationalOrganization", "@id" => "#{root_url}#school",
          "name" => t("site.name"), "url" => root_url,
          "description" => t("site.meta_description"),
          "logo" => image_url("og-image.png"),
          "founder" => owner_structured_data
        }
      ]
    }
  end

  def article_structured_data(article)
    data = {
      "@context" => "https://schema.org", "@type" => "Article",
      "headline" => article.title.truncate(110),
      "description" => meta_description(article.summary),
      "url" => article_url_for(article),
      "inLanguage" => article.locale,
      "author" => owner_structured_data,
      "publisher" => { "@type" => "EducationalOrganization", "name" => t("site.name"), "url" => root_url },
      "datePublished" => article.published_at&.iso8601,
      "dateModified" => article.updated_at.iso8601
    }
    data["image"] = article_cover_url_for(article) if article.cover_image.attached?
    data.compact
  end

  def course_structured_data(course)
    {
      "@context" => "https://schema.org", "@type" => "Course",
      "name" => course.title,
      "description" => meta_description(course.summary.presence || course.subtitle),
      "url" => course_url(id: course),
      "inLanguage" => course.locale,
      "provider" => { "@type" => "EducationalOrganization", "name" => t("site.name"), "url" => root_url },
      "instructor" => owner_structured_data
    }
  end

  private
    def owner_structured_data
      {
        "@type" => "Person", "name" => OWNER_NAME,
        "jobTitle" => "Médica psiquiatra",
        "url" => about_url,
        "sameAs" => social_links.first(4).pluck(:url)
      }
    end
end
