class Groups::NewsController < ApplicationController

  include GroupMethods
  include NewsItemMethods

  before_filter :login_required, :except => [:index, :show]
  before_filter :get_group
  before_filter :setup
  before_filter :authorization_required, :only => [:new, :edit, :create, :update, :destroy] 
  before_filter :get_news_item, :except => [:new, :create, :index]

  cache_sweeper :group_news_sweeper, :only => [:create, :update, :destroy]

  uses_tiny_mce(:options => GlobalConfig.news_mce_options,
                :only => [:new, :create, :edit, :update])
                
  def index
    @news = @group.news_items.paginate(:page => @page, :per_page => @per_page)
    respond_to do |format|
      format.html # index.html.erb
      format.xml { render :xml => @news }
      format.js do
        root_part = group_news_index_path(@group) + '/'  
        render :json => autocomplete_urls_json(@news, root_part).to_json 
      end
    end
  end

  def show
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @news_item }
    end
  end

  def new
    @news_item = @group.news_items.build
    
    respond_to do |format|
      format.html
      format.xml  { render :xml => @news_item }
    end
  end

  def edit
    respond_to do |format|
      format.html
      format.xml  { render :xml => @news_item }
    end
  end

  def create
    @news_item = @group.news_items.build(params[:news_item])
    @news_item.creator = current_user
    respond_to do |format|
      if @news_item.save
        flash[:notice] = 'NewsItem was successfully created.'
        format.html { redirect_to(group_news_path(@group, @news_item)) }
        format.xml  { render :xml => @news_item, :status => :created, :location => @news_item }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @news_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @news_item.update_attributes(params[:news_item])
        flash[:notice] = 'News item was successfully updated.'
        format.html { redirect_to(group_news_path(@group, @news_item)) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @news_item.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @news_item.destroy
    flash[:notice] = "News item '#{@news_item.title}' was successfully deleted."
    respond_to do |format|
      format.html { redirect_to(group_news_index_path(@group)) }
      format.xml  { head :ok }
    end
  end

  private

  def setup
    @user = current_user
  end

  def permission_denied 
    flash[:error] = _("You don't have permission manage the news for this group.")     
    respond_to do |format|
      format.html do
        redirect_to group_news_index_path(@group)
      end
    end
  end

end
