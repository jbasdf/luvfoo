xml.instruct! :xml, :version=>"1.0"
xml.rss(:version=>"2.0"){
  xml.channel do
    xml.title "#{GlobalConfig.application_name} Activity Feed"
    xml.link GlobalConfig.application_url
    xml.description "This feed will quickly show you what has recently happened on #{GlobalConfig.application_name} without having to login."
    xml.language 'en-us'
    @feed_items.each do |feed_item|
      next if feed_item.partial == 'nil_class'
      render :partial => "feed_items/#{feed_item.partial}", :locals => {:feed_item => feed_item, :xml_instance => xml}
    end
}
