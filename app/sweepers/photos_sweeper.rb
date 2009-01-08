class PhotosSweeper < ActionController::Caching::Sweeper
  observe Photo
  
  def after_create(photo)
    expire_cache_for(photo)
  end
  
  def after_update(photo)
    expire_cache_for(photo)
  end
  
  def after_destroy(photo)
    expire_cache_for(photo)
  end
  
  private
  
  def expire_cache_for(photo)
    expire_fragment(:controller => '/home', :action => 'home')
  end
end