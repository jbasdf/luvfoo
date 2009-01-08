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
    expire_fragment(:controller => '/groups', :action => 'index', :visibility => -1, :page => 1, :per_page => 40)
    expire_fragment(:controller => '/groups', :action => 'index', :visibility => 0, :page => 1, :per_page => 40)
    expire_fragment(:controller => '/groups', :action => 'index', :visibility => 0, :page => 1, :per_page => 40, :index => group.name[0,1])
    expire_fragment(:controller => '/groups', :action => 'index', :visibility => -1, :page => 1, :per_page => 40, :index => group.name[0,1])
  end
  
end