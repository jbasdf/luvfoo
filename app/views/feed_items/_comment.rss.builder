c ||= comment
c ||= feed_item.item

xml = xml_instance unless xml_instance.nil?
xml.item do
  xml.title commentable_text(c, false)
  xml.link user_feed_item_url(@user, c)
  xml.guid user_feed_item_url(@user, c)
  xml.description sanitize(textilize(c.comment))
  xml.author "#{c.user.email} (#{c.user.f})"
  xml.pubDate c.updated_at
end