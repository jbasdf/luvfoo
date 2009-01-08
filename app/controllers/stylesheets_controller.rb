class StylesheetsController < ApplicationController

  layout false
  
  skip_filter :login_from_cookie, :setup_paging, :set_locale_from_param
  skip_filter :store_location
  
  caches_page :custom  
  
  def custom  
    respond_to do |format|
      format.css { render }
    end      
  end
  
end
