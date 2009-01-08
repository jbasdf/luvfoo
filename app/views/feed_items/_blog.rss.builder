xml = xml_instance unless xml_instance.nil?
xml.item do
  blog = feed_item.item
  xml.title "#{blog.user.full_name} blogged #{time_ago_in_words blog.created_at} #{blog.title}"
  xml.description sanitize(textilize(blog.body))
  xml.author "#{blog.user.email} (#{blog.user.f})"
  xml.pubDate blog.updated_at
  xml.link user_blog_url(blog.user, blog)
  xml.guid user_blog_url(blog.user, blog)
end