class LatestNewsSweeper < ActionController::Caching::Sweeper
  observe NewsItem

  def after_create(news_item)
    expire_cache_for(news_item)
  end
  
  def after_update(news_item)
    expire_cache_for(news_item)
  end
  
  def after_destroy(news_item)
    expire_cache_for(news_item)
  end
          
  private
  
  def expire_cache_for(news_item)
    if news_item.newsable_type == 'User' && news_item.newsable.has_role?('contributor')
      expire_fragment(:controller => '/home', :action => 'home')
    end
  end
end