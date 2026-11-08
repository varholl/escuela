xml.instruct! :xml, version: "1.0", encoding: "UTF-8"
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9" do
  standing = {
    root_url => "home", about_url => "about", philosophy_url => "philosophy",
    privacy_url => "privacy", terms_url => "terms"
  }
  standing.each do |url, key|
    xml.url do
      xml.loc url
      xml.lastmod @pages[key].updated_at.to_date.iso8601 if @pages[key]
    end
  end

  [ reflections_url, notes_url, courses_url ].each { |url| xml.url { xml.loc url } }

  @articles.each do |article|
    xml.url do
      xml.loc article_url_for(article)
      xml.lastmod article.updated_at.to_date.iso8601
    end
  end

  @courses.each do |course|
    xml.url do
      xml.loc course_url(id: course)
      xml.lastmod course.updated_at.to_date.iso8601
    end
  end
end
