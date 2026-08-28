# Privacy and terms describe what the code actually does, so they go stale the
# moment the system changes. The seed only fills a page that is still empty,
# which is right for her own writing but wrong for these two: they are
# maintained in db/legal_content.rb, not in the panel.
namespace :legal_content do
  desc "Rewrite the privacy and terms pages from db/legal_content.rb"
  task refresh: :environment do
    require Rails.root.join("db/legal_content")

    LEGAL_CONTENT.each do |(key, locale), attributes|
      page = Page.find_or_create_by!(key: key, locale: locale)
      page.title = attributes[:title]
      page.subtitle = attributes[:subtitle]
      page.body = attributes[:body]
      page.save!

      puts "  rewrote #{key} (#{locale})"
    end
  end
end
