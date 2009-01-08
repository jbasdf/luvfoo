class SiteSweeper < ActionController::Caching::Sweeper
  observe Site

  def after_save(site)
    expire_page(:controller => "/stylesheets", :action => 'custom', :format => 'css')
  end
  
end