require "test_helper"

class SocialHelperTest < ActionView::TestCase
  include SocialHelper

  test "every profile is a complete https url with a glyph" do
    assert_equal 6, social_links.size

    social_links.each do |link|
      assert link[:url].start_with?("https://"), "#{link[:label]} is not https"
      assert link[:label].present?
      assert_includes %i[ instagram youtube spotify facebook ], link[:icon]
    end
  end

  test "the two accounts on the same network are told apart" do
    labels = social_links.map { |link| link[:label] }

    assert_equal labels.uniq, labels
  end
end
