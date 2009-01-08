xml.instruct! :xml, :version=>"1.0"
xml.rss(:version=>"2.0") do
  xml.channel do
    xml.title "#{@user.f}'s Blog"
    xml.link GlobalConfig.application_url
    xml.description "#{@user.f}'s Blog at #{GlobalConfig.application_name}"
    xml.language 'en-us'
    @blogs.each do |blog|
      xml.item do
        xml.title blog.title
        xml.description body_content(blog)
        xml.author "#{@user.f}"
        xml.pubDate @user.created_at
        xml.link user_blog_url(@user, blog)
        xml.guid user_blog_url(@user, blog)
      end
    end
  end
end

