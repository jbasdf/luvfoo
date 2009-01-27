class SitePhotosController < ApplicationController
  
  def index
    @admin = is_admin?
    @photos = Photo.paginate :page => @page, :per_page => 20, :order => 'created_at DESC'
  end
  
end
