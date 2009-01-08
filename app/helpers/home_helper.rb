module HomeHelper
  
  def newest_pictures limit = 7
    Photo.find(:all, :order => 'created_at desc', :limit => limit)
  end
  
  def recent_comments limit = 10
    Comment.find(:all, :order => 'created_at desc', :limit => limit, :conditions => "commentable_type='User'")
  end
  
  def new_members limit = 16
    User.find(:all, :limit => limit, :conditions => 'icon IS NOT null', :order => 'created_at DESC')
  end
  
  def latest_group_news limit = 4
    NewsItem.find(:all, :order => 'created_at desc', :limit => limit, :joins => 'news_items, groups', :conditions => "newsable_type='Group' AND groups.id = news_items.newsable_id AND groups.visibility > 1")
  end
  
  def country_pages
    ContentPage.tagged_with('HomeCountries', :on => :menus).by_alpha
  end
  
  def about_us_pages
    ContentPage.tagged_with('HomeAboutUs', :on => :menus).by_alpha
  end

end
