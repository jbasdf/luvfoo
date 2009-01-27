class Admin::PagesController < Admin::BaseController

  include PageMethods
  include JsonMethods
  
  before_filter :get_user
  before_filter :get_site
  before_filter :get_site_content_page, :only => [:edit, :update, :destroy]

  uses_tiny_mce(:options => GlobalConfig.advanced_mce_options.merge(:save_onsavecallback => 'save_page'),
                :raw_options => GlobalConfig.raw_mce_options,
                :only => [:edit, :update])
                
  uses_tiny_mce(:options => GlobalConfig.advanced_mce_options,
                :raw_options => GlobalConfig.raw_mce_options, 
                :only => [:new, :create])
  
  cache_sweeper :page_sweeper, :only => [:create, :update, :destroy]

  def index
    @pages = @site.pages.by_alpha
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @pages }
      format.js do
        root_part = pages_path + '/'
        render :json => autocomplete_urls_json(@pages, root_part).to_json
      end
    end
  end
  
  def new
    @content_page = ContentPage.new
    @content_page.parent_id = params[:parent_id] if params[:parent_id]
    @content_page.locale = default_locale
    respond_to do |format|
      format.html
      format.xml  { render :xml => @content_page }
    end
  end

  def create
    @content_page = @site.pages.build params[:content_page]
    @content_page.creator = current_user
    
    respond_to do |format|
      if @content_page.save
        format.html do
          flash[:notice] = _('Page saved')
          redirect_to admin_pages_path
        end
        format.js { render :text => _('Page saved') }
      else
        format.html do
          flash.now[:error] = _('Failed to create a new page')
          render :action => :new
        end
        format.js { render :text => _('Failed to create a new page') }
      end
    end
  end

  def edit
    respond_to do |format|
      format.html
      format.xml  { render :xml => @content_page }
    end
  end

  def update
    expire_action(:controller => '/home', :action => 'home')
    message = ''
    @results = Hash.new
    if params[:only_permalink]
      @content_page.permalink = params[:url_key]
      if @content_page.save
        success = true
        message = _('Updated permalink')
      else
        success = false
        message = _('Failed to update permalink')
      end
      @results[:url_key] = @content_page.url_key
    elsif params[:only_parent]
       @content_page.parent_id = params[:parent_id]
       if @content_page.save
         success = true
         message = _('Updated parent id')
       else
         success = false
         message = _('Failed to update parent id')
       end
       @results[:parent_id] = params[:parent_id] 
    else
      if @content_page.update_attributes(params[:content_page])
        success = true
        message = _('Page saved')
      else
        success = false
        message = _('Failed to update page')
      end
    end
    
    @results[:success] = success
    @results[:message] = message
    
    respond_to do |format|
      format.html do
        flash[:notice] = message
        render :action => :edit
      end
      format.js do
        render :json => @results.to_json
      end
    end
  end

  def destroy
    @content_page.destroy
    msg = "Page '#{@content_page.title}' was successfully deleted."
    respond_to do |format|
      format.js { render :text => msg }
      format.html do
        flash[:notice] = msg
        redirect_to admin_pages_path
      end
      format.xml  { head :ok }
    end
  end

end
