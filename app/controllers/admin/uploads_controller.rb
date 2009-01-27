class Admin::UploadsController < Admin::BaseController

  include PageMethods
  include JsonMethods
  
  before_filter :get_site

  def images
    @images = @site.uploads.images.paginate(:page => @page, :per_page => @per_page, :order => 'created_at desc')
    #render :partial => 'uploads/editor_icon', :collection => @images
    respond_to do |format|
      format.js { render :json => basic_uploads_json(@images) }
    end
  end
  
  def files
    @files = @site.uploads.files.paginate(:page => @page, :per_page => @per_page, :order => 'created_at desc')
    respond_to do |format|
      format.js { render :json => basic_uploads_json(@files) }
    end
  end
  
end
