require "test_helper"

class RichTextHelperTest < ActionView::TestCase
  include RichTextHelper

  EMBED = "https://www.youtube-nocookie.com/embed/ihmc2fKshLA?rel=0"

  def iframes(html)
    Nokogiri::HTML5.fragment(with_video_embeds(html)).css("iframe")
  end

  test "a youtube link alone on a line becomes a player" do
    frames = iframes(%(<div>Mirá esto:<br><a href="https://youtu.be/ihmc2fKshLA">https://youtu.be/ihmc2fKshLA</a><br>Y después seguimos.</div>))

    assert_equal [ EMBED ], frames.map { |frame| frame["src"] }
  end

  test "keeps the text around the video" do
    html = with_video_embeds(%(<div>Antes<br>https://www.youtube.com/watch?v=ihmc2fKshLA<br>Después</div>))

    assert_includes html, "Antes"
    assert_includes html, "Después"
    assert_not_includes html, "watch?v="
  end

  test "the embed code youtube hands out, dropped into a code block" do
    snippet = %(<iframe width="560" height="315" src="https://www.youtube.com/embed/ihmc2fKshLA?si=u7UZoTr2ehL_Vhlc" ) +
      %(title="YouTube video player" frameborder="0" allow="autoplay" referrerpolicy="strict-origin-when-cross-origin" allowfullscreen></iframe>)
    frames = iframes("<pre>#{ERB::Util.html_escape(snippet)}</pre>")

    assert_equal [ EMBED ], frames.map { |frame| frame["src"] }
  end

  test "the same embed code typed as a plain paragraph" do
    snippet = %(<iframe src="https://www.youtube.com/embed/ihmc2fKshLA"></iframe>)

    assert_equal [ EMBED ], iframes("<div>#{ERB::Util.html_escape(snippet)}</div>").map { |frame| frame["src"] }
  end

  test "a vimeo link alone on a line becomes a player" do
    assert_equal [ "https://player.vimeo.com/video/123456789" ],
      iframes("<div>https://vimeo.com/123456789</div>").map { |frame| frame["src"] }
  end

  test "a link inside a sentence stays a link" do
    assert_empty iframes(%(<div>Lo conté en <a href="https://youtu.be/ihmc2fKshLA">este video</a> hace poco.</div>))
    assert_empty iframes("<div>Está en https://youtu.be/ihmc2fKshLA si querés verlo.</div>")
  end

  test "an embed snippet pointing anywhere else is left as text" do
    snippet = %(<iframe src="https://example.com/embed/ihmc2fKshLA"></iframe>)

    assert_empty iframes("<pre>#{ERB::Util.html_escape(snippet)}</pre>")
  end

  test "a link that only looks like youtube is not trusted" do
    assert_empty iframes("<div>https://evil.example/watch?v=ihmc2fKshLA</div>")
  end

  test "other code blocks are untouched" do
    html = with_video_embeds("<pre>puts \"hola\"</pre>")

    assert_includes html, "<pre>"
    assert_empty iframes("<pre>puts \"hola\"</pre>")
  end
end
