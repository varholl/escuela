# The sample notes, courses and biographies exist so the site is not a blank
# page while the real copy is being written. They read as the owner's own
# words, so there has to be a one-command way to take them back out.
namespace :sample_content do
  # She rewrote the three sample notes and turned fundamentos-de-atencion-plena
  # into her own course (Mindfulness para la Promoción de la Salud) under the
  # same slugs, so they are hers now and must never be swept up by `remove`.
  SAMPLE_ARTICLE_SLUGS = %w[].freeze

  SAMPLE_COURSE_SLUGS = %w[
    introduccion-a-la-respiracion
    habitar-el-cuerpo
  ].freeze

  desc "Remove the seeded sample notes, courses and page copy"
  task remove: :environment do
    articles = Article.where(slug: SAMPLE_ARTICLE_SLUGS)
    courses  = Course.where(slug: SAMPLE_COURSE_SLUGS)

    puts "  removing #{articles.count} sample notes and #{courses.count} sample courses"
    articles.destroy_all
    courses.destroy_all

    # Only blank a page that still holds the seeded copy, so anything she has
    # already rewritten is left alone.
    Page.find_each do |page|
      next unless page.body.to_plain_text.include?("Reemplazá este texto") ||
                  page.body.to_plain_text.include?("Replace this text")

      page.body = nil
      page.update!(title: nil, subtitle: nil)
      puts "  cleared #{page.key}/#{page.locale}"
    end

    puts "  done -- notes: #{Article.count}, courses: #{Course.count}"
  end

  desc "List what is still sample content"
  task list: :environment do
    puts "notes:   #{Article.where(slug: SAMPLE_ARTICLE_SLUGS).pluck(:title).join(', ').presence || 'none'}"
    puts "courses: #{Course.where(slug: SAMPLE_COURSE_SLUGS).pluck(:title).join(', ').presence || 'none'}"

    pages = Page.select { |p| p.body.to_plain_text.match?(/Reemplazá este texto|Replace this text/) }
    puts "pages:   #{pages.map { |p| "#{p.key}/#{p.locale}" }.join(', ').presence || 'none'}"
  end
end
