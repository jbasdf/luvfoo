class ProfilesController < ApplicationController

  include ApplicationHelper
  include SearchHelper
  include RssMethods

  before_filter :search_results, :only => [:index, :search]

  def index
    render
  end

  def search
    render :template => 'profiles/index'
  end

  # show a given user's public profile information
  def show

    @per_page = 10

    @user = User.find_by_login(params[:id])

    @google_docs = @user.public_google_docs
    @shared_entries = @user.public_shared_entries

    if @user.nil?
      flash[:notice] = _("Could not find the specified user.")
      redirect_to profiles_path
      return
    end

    @message = Message.new
    @message.receiver_id = @user.id

    @to_list = [@user] if logged_in? && (current_user.friend_of?(@user) || is_admin?)

    unless @user.youtube_username.blank?
      begin
        client = YouTubeG::Client.new
        @video = client.videos_by(:user => @user.youtube_username).videos.first
      rescue Exception, OpenURI::HTTPError
      end
    end

    begin
      @flickr = @user.flickr_username.blank? ? [] : flickr_images(flickr.people.findByUsername(@user.flickr_username))
    rescue Exception, OpenURI::HTTPError
      @flickr = []
    end    

    @comments = @user.comments.paginate(:page => @page, :per_page => @per_page)
    @blogs = @user.blogs.paginate(:page => @page, :per_page => @per_page)
    @total_blogs = @user.blogs.count

    if GlobalConfig.integrate_portfolio
      uri = GlobalConfig.portfolio_url_template.sub('{user_login}', @user.login)    
      uri = "http://courses.teacherswithoutborders.org/junk"        
      @portfolio_rss = RssMethods::get_rss(uri, 5) rescue nil
    end

    if @user.blog_rss          
      @blog_rss = RssMethods::get_rss(@user.blog_rss , 5) rescue nil
    end

    respond_to do |format|
      format.html do
        @feed_items = @user.my_feed_items.paginate(:page => @page, :per_page => @per_page)
      end
      format.rss do 
        @feed_items = @user.my_feed_items.paginate(:page => @page, :per_page => @per_page)
        render :layout => false
      end
    end
  end

  private

  def search_results
    @query = params[:q]
    @per_page = 20
    @browse = @query ? 'search' : params[:browse] || 'date' 

    #      field_list = logged_in? ? 'protected_profile AS profile' : 'public_profile AS profile'
    #      field_list = 'public_profile AS profile'
    field_list = '*'

    @query = nil if (@query == '*') 

    if !@query.nil?
      @results = User.find_by_solr("#{search_field}:(#{@query})", :offset => (@page-1)*@per_page, :limit => @per_page).results

    elsif @browse == 'alpha'
      @alpha_index = params[:alpha_index] || 'A'
      @results = User.find(:all, :select => field_list, :conditions => ["last_name LIKE ?", @alpha_index + '%'], :order => 'last_name, first_name').paginate(:page => @page, :per_page => @per_page)

    else
      @results = User.find(:all, :select => field_list, :order => 'created_at DESC').paginate(:page => @page, :per_page => @per_page)
    end
    flash[:notice] = @results.empty? ? _('No profiles were found that matched your search.') : nil
  end

end
