class Groups::UploadsController < ApplicationController

  include UserMethods
  include GroupMethods
  include JsonMethods
   
  before_filter :get_user
  before_filter :get_group

  def index
    @upload = Upload.new
    @parent = @group
    if @group.is_member?(@user)
      @uploads = @group.uploads.paginate(:page => @page, :per_page => @per_page, :order => 'created_at desc')
    else
      @uploads = @group.uploads.public.paginate(:page => @page, :per_page => @per_page, :order => 'created_at desc')
    end
    respond_to do |format|
      format.html { render }
      format.rss { render :layout => false }
    end
  end

  def photos
    if @group.is_member?(@user)
      @images = @group.uploads.images.paginate(:page => @page, :per_page => @per_page, :order => 'created_at desc')
    else
      @images = @group.uploads.images.public.paginate(:page => @page, :per_page => @per_page, :order => 'created_at desc')
    end
    respond_to do |format|
      format.html { render }
      format.rss { render :layout => false }
    end
  end

  # for tinymce image manger
  def images
    if @group.is_member?(@user)
      @images = @group.uploads.images.paginate(:page => @page, :per_page => @per_page, :order => 'created_at desc')
    else
      @images = @group.uploads.images.public.paginate(:page => @page, :per_page => @per_page, :order => 'created_at desc')
    end
    respond_to do |format|
      format.js { render :json => basic_uploads_json(@images) }
    end
  end
  
  def files
    if @group.is_member?(@user)
      @files = @group.uploads.paginate(:page => @page, :per_page => @per_page, :order => 'created_at desc')
    else
      @files = @group.uploads.public.paginate(:page => @page, :per_page => @per_page, :order => 'created_at desc')
    end
    respond_to do |format|
      format.js { render :json => basic_uploads_json(@files) }
    end
  end
  
end