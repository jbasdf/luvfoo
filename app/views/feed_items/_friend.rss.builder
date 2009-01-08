xml = xml_instance unless xml_instance.nil?
xml.item do
  friend = feed_item.item
  xml.title "#{friend.inviter.full_name} is now a #{friend.description friend.inviter} of #{friend.invited.full_name}"
  xml.description "#{friend.inviter.full_name}'s network in #{GlobalConfig.application_name} has been updated."
  xml.author "#{friend.invited.email} (#{friend.invited.full_name})"
  xml.pubDate feed_item.created_at
  xml.link profile_url( (@user==friend.invited ? friend.inviter : friend.invited ) )
  xml.guid profile_url( (@user==friend.invited ? friend.inviter : friend.invited ) )
end
