class ForumsController < ApplicationController
	
	include ForumMethods
  
	before_filter :login_required, :except => [:index, :show]
  before_filter :find_forum, :only => [:show, :update, :destroy]
	before_filter :admin?, :except => [:show, :index]

  cache_sweeper :posts_sweeper, :only => [:create, :update, :destroy]

  def index
    @forums = Forum.site_forums.by_position    
    # reset the page of each forum we have visited when we go back to index
    session[:forum_page] = nil
    respond_to do |format|
      format.html
      format.xml { render :xml => @forums }
    end
  end

  def show
    respond_to do |format|
      format.html do
        setup_show_forum
      end
      format.xml { render :xml => @forum }
    end
  end

  def new
    @forum = Forum.new
    render
  end
  
  def create
    @forum = Forum.new(params[:forum])
    @forum.save!
    respond_to do |format|
      format.html { redirect_to forum_path(@forum) }
      format.xml  { head :created, :location => formatted_forum_url(@forum, :xml) }
    end
  end

  def update
    @forum.update_attributes!(params[:forum])
    respond_to do |format|
      format.html { redirect_to @forum }
      format.xml  { head 200 }
    end
  end
  
  def destroy
    @forum.destroy
    respond_to do |format|
      format.html { redirect_to forums_path }
      format.xml  { head 200 }
    end
  end
  
  protected
  alias authorized? admin?
end
