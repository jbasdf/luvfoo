class Users::UploadsController < ApplicationController

  include UserMethods

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

end