xml.instruct! :xml, version: "1.0"
xml.rss version: "2.0", "xmlns:atom" => "http://www.w3.org/2005/Atom" do
  xml.channel do
    xml.title "Jeremy Ward Dev Blog"
    xml.description "Build-in-public updates, Rails insights, and lessons from 20 years shipping code."
    xml.link root_url
    xml.language "en"
    xml.tag! "atom:link", href: blog_feed_url(format: :rss), rel: "self", type: "application/rss+xml"

    @posts.each do |post|
      xml.item do
        xml.title post.title
        xml.description post.excerpt
        xml.link blog_post_url(post.slug)
        xml.guid blog_post_url(post.slug), isPermaLink: true
        xml.pubDate post.date.to_time.rfc2822 if post.date
        xml.tag!("content:encoded") { xml.cdata!(post.body) } if post.body
      end
    end
  end
end
