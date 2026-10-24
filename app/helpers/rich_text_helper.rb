module RichTextHelper
  # Trix has no video button, and Action Text strips any <iframe> she pastes --
  # rightly, since letting stored HTML through would let it point anywhere. So a
  # video is written the way she would share one: its link alone on a line, or
  # the embed code YouTube offers, typed or dropped into a code block. Here, on
  # the way out and after sanitising, that line becomes a player.
  #
  # Only whole lines count. A link in the middle of a sentence stays a link.
  def with_video_embeds(html)
    fragment = Nokogiri::HTML5.fragment(html.to_s)

    fragment.css("pre").each do |block|
      if (url = VideoEmbed.from_text(block.text))
        block.replace(video_embed_node(fragment, url))
      end
    end

    fragment.css("div, p").each do |block|
      lines_of(block).each do |line|
        next unless line.all? { |node| node.text? || node.name == "a" }
        next unless (url = VideoEmbed.from_text(line.sum("", &:text)))

        # The <br> that ended the line would leave a blank one under the player.
        line.last.next_sibling&.then { |br| br.remove if br.name == "br" }
        line.first.add_previous_sibling(video_embed_node(fragment, url))
        line.each(&:remove)
      end
    end

    fragment.to_html.html_safe
  end

  private
    # Trix writes one block per paragraph and separates lines inside it with
    # <br>, so a "line" is a run of a block's children between two of those.
    def lines_of(block)
      block.children
        .slice_when { |a, b| a.name == "br" || b.name == "br" }
        .reject { |nodes| nodes.all? { |node| node.name == "br" || (node.text? && node.text.strip.empty?) } }
        .map { |nodes| nodes.reject { |node| node.text? && node.text.strip.empty? } }
    end

    def video_embed_node(fragment, url)
      figure = Nokogiri::XML::Node.new("figure", fragment.document)
      figure["class"] = "video-embed"

      iframe = Nokogiri::XML::Node.new("iframe", fragment.document)
      iframe["src"] = url
      iframe["title"] = t("rich_text.video_title")
      iframe["loading"] = "lazy"
      iframe["referrerpolicy"] = "strict-origin-when-cross-origin"
      iframe["allow"] = "accelerometer; autoplay; clipboard-write; encrypted-media; picture-in-picture; fullscreen"
      iframe["allowfullscreen"] = ""

      figure.add_child(iframe)
      figure
    end
end
