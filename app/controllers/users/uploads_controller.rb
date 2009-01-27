class Users::UploadsController < ApplicationController

  include UserMethods
  include JsonMethods
 
  before_filter :login_required
  before_filter :get_user

  def index
    @upload = Upload.new
    @parent = @user
    @uploads = @user.uploads.paginate(:page => @page, :per_page => @per_page, :order => 'created_at desc')
    respond_to do |format|
      format.html { render }
      format.rss { render :layout => false }
    end
  end

  def photos
    @images = @user.uploads.images.paginate(:page => @page, :per_page => @per_page, :order => 'created_at desc')
    respond_to do |format|
      format.html { render }
      format.rss { render :layout => false }
    end
  end

  # for tinymce image manger
  def images
    @images = @user.uploads.images.paginate(:page => @page, :per_page => @per_page, :order => 'created_at desc')
    respond_to do |format|
      format.js { render :json => basic_uploads_json(@images) }
    end
  end
  
  def files
    @files = @user.uploads.files.paginate(:page => @page, :per_page => @per_page, :order => 'created_at desc')
    respond_to do |format|
      format.js { render :json => basic_uploads_json(@files) }
    end
  end
  
end