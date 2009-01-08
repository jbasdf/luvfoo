class ProfileSweeper < ActionController::Caching::Sweeper
  observe User

  def after_update(user)
    expire_cache_for(user)
  end
  
  private
  
  def expire_cache_for(user)
    expire_fragment(:controller => '/home', :action => 'home')
  end
end