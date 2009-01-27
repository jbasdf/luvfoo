class Admin::MemberStoriesController < Admin::BaseController

  include NewsItemMethods
  before_filter :setup
  before_filter :get_news_item, :only => [:show, :update, :edit, :destroy]
  
  cache_sweeper :member_stories_sweeper, :only => [:create, :update, :destroy]
                
  uses_tiny_mce(:options => GlobalConfig.advanced_mce_options,
                :raw_options => GlobalConfig.raw_mce_options, 
                :only => [:new, :create, :edit, :update])
                
  def index
    @news_items = @widget.news_items.paginate(:page => @page, :per_page => @per_page)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @news_items }
      format.json do
        root_part = admin_member_stories_path + '/' 
        render :json => autocomplete_urls_json(@news_items, root_part)
      end
    end
  end

  def show
    render
  end

  def new
    @news_item = @widget.news_items.build
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @news_item }
    end
  end

  def edit
    render
  end

  def create
    @news_item = @widget.news_items.build(params[:news_item])
    saved = @news_item.save

    respond_to do |format|
      if saved
        flash[:notice] = 'Member Story was successfully created.'
        format.html { redirect_to admin_member_stories_url }
        format.xml  { render :xml => @news_item, :status => :created, :location => @widget }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @news_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @news_item.update_attributes(params[:news_item])
        flash[:notice] = "Member story '#{@news_item.title}' was successfully updated."
        format.html { redirect_to admin_member_stories_url }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @news_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @news_item.destroy
    flash[:notice] = "Member story '#{@news_item.title}' was successfully deleted."
    respond_to do |format|
      format.html { redirect_to admin_member_stories_url }
      format.xml  { head :ok }
    end
  end

  private

  def setup
    @widget = Widget.find_or_create_by_name(:member_stories)
  end
 
end
