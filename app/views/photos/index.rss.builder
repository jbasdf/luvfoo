xml.instruct! :xml, :version=>"1.0"
xml.rss(:version=>"2.0") do
  xml.channel do
    xml.title "#{@user.f}'s Blog"
    xml.link GlobalConfig.application_url
    xml.description "#{@user.f}'s Blog at #{GlobalConfig.application_name}"
    xml.language 'en-us'
    @photos.each do |photo|
      xml.item do
        xml.title "Photo"
        xml.description "<a href=\"#{user_photo_url(@user, photo)}\" title=\"#{photo.caption}\" alt=\"#{photo.caption}\" class=\"thickbox\" rel=\"user_gallery\">#{image photo, :small}</a>" + photo.caption
        xml.author "#{@user.f}"
        xml.pubDate @user.created_at
        xml.link user_photo_url(@user, photo)
        xml.guid user_photo_url(@user, photo)
      end
    end
  end
end

