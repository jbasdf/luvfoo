class GroupEventsSweeper < ActionController::Caching::Sweeper
  observe Event

  def after_create(event)
    expire_cache_for(event)
  end
  
  def after_update(event)
    expire_cache_for(event)
  end
  
  def after_destroy(event)
    expire_cache_for(event)
  end
          
  private
  
  def expire_cache_for(event)
    if event.eventable_type == 'Group'
      expire_page(:controller => '/groups/events', :action => 'index')
      expire_page(:controller => "/groups/events", :action => 'index', :format => 'css')
    end
  end
  
end