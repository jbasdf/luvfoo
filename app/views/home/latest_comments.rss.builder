
xml.instruct! :xml, :version=>"1.0"
xml.rss(:version=>"2.0") do
  xml.channel do
    xml.title "#{GlobalConfig.application_name} Latest Comments Feed"
    xml.link GlobalConfig.application_url
    xml.description "All the action for #{GlobalConfig.application_name}"
    xml.language 'en-us'
    recent_comments.each do |c|
      xml.item do
        xml.title commentable_text(c, false)
        xml.link user_feed_item_url(@user, c)
        xml.guid user_feed_item_url(@user, c)
        xml.description sanitize(textilize(c.comment))
        xml.author "#{c.user.email} (#{c.user.f})"
        xml.pubDate c.updated_at
      end
    end
  end
end
