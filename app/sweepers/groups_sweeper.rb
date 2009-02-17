class GroupsSweeper < ActionController::Caching::Sweeper
  observe Group

  def after_create(group)
    expire_cache_for(group)
  end
  
  def after_update(group)
    expire_cache_for(group)
  end
  
  def after_destroy(group)
    expire_cache_for(group)
  end
          
  private
  
  def expire_cache_for(group)
    expire_fragment(%r{groups.*})
  end
  
end