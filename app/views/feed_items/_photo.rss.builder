xml = xml_instance unless xml_instance.nil?
xml.item do
  photo = feed_item.item
  xml.title "#{photo.photoable.full_name} uploaded a photo"
  xml.description photo.caption.blank? ? 'No caption provided' : sanitize(textilize(photo.caption))
  xml.author "#{photo.photoable.email} (#{photo.photoable.full_name})"
  xml.pubDate photo.updated_at
  xml.link user_photo_url(photo.photoable, photo)
  xml.guid user_photo_url(photo.photoable, photo)
end