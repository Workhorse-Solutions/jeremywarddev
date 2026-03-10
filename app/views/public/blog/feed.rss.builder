xml.instruct! :xml, version: "1.0"
xml.rss version: "2.0", "xmlns:atom" => "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.title "#{ENV.fetch('APP_NAME', 'Blog')} Blog"
    xml.link blog_url
    xml.description "Latest posts"
    xml.language "en-us"
    xml.tag! "atom:link", href: blog_feed_url(format: :rss), rel: "self", type: "application/rss+xml"

    @posts.each do |post|
      xml.item do
        xml.title post.title
        xml.link blog_post_url(slug: post.slug)
        xml.guid blog_post_url(slug: post.slug), isPermaLink: "true"
        xml.pubDate post.published_at.to_fs(:rfc822)
        xml.description do
          xml.cdata! post.body_html
        end
      end
    end
  end
end
