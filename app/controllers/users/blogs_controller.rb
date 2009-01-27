class Users::BlogsController < ApplicationController

  # blogs are just news_items attached to a given user

  #web_service_api BloggerAPI

  include ApplicationHelper
  include NewsItemMethods
  include UserMethods
  
  before_filter :login_required
  before_filter :get_user
  before_filter :authorization_required
  before_filter :get_news_item, :only => [:edit, :update, :destroy]

  cache_sweeper :latest_news_sweeper, :only => [:create, :update, :destroy]

  uses_tiny_mce(:options => GlobalConfig.news_mce_options,
                :only => [:new, :create, :edit, :update])
                
  def index
    @blogs = @user.blogs.paginate(:page => @page, :per_page => @per_page)
    respond_to do |format|
      format.html {render}
      format.rss {render :layout=>false}
      format.js do
        root_part = user_blogs_path(@user) + '/' 
        render :json => autocomplete_urls_json(@blogs, root_part) 
      end
    end
  end

  def new
    @news_item = @user.blogs.build
    render
  end

  def create
    @news_item = current_user.blogs.build(params[:news_item])
    @news_item.creator = current_user

    respond_to do |format|
      if @news_item.save
        format.html do
          flash[:notice] = _('New blog post created.')
          redirect_to user_blogs_path(@user)
        end
      else
        format.html do
          flash.now[:error] = _('Failed to create a new blog post.')
          render :action => :new
        end
      end
    end
  end

  def edit
    render
  end

  def update
    respond_to do |format|
      if @news_item.update_attributes(params[:news_item])
        format.html do
          flash[:notice]=_('Blog post updated.')
          redirect_to user_blogs_path(@user)
        end
      else
        format.html do
          flash.now[:error]=_('Failed to update the blog post.')
          render :action => :edit
        end
      end
    end
  end

  def destroy
    if @news_item.can_edit?(@user)
      @news_item.destroy
      flash[:notice]=_('Blog post deleted.')
    else
      flash[:notice]=_("You don't have permission to delete this blog post.")
    end
    respond_to do |format|
      format.html do
        redirect_to user_blogs_path(@user)
      end
    end
  end

end
