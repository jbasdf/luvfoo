class TopicsController < ApplicationController
  
  include ForumMethods

  before_filter :find_forum
  before_filter :find_topic, :except => :index  
  before_filter :login_required, :except => [:index, :show]  
  
  caches_formatted_page :rss, :show
  cache_sweeper :posts_sweeper, :only => [:create, :update, :destroy]

  def index
    respond_to do |format|
      format.html { redirect_to get_forum_redirect }
      format.xml do
        @topics = Topic.paginate_by_forum_id(@forum.id, :order => 'sticky desc, replied_at desc', :page => @page, :per_page => @per_page)
        render :xml => @topics.to_xml
      end
    end
  end
  
  def show
    respond_to do |format|
      format.html do
        # see notes in application.rb on how this works
        update_last_seen_at
        # keep track of when we last viewed this topic for activity indicators
        (session[:topics] ||= {})[@topic.id] = Time.now.utc if logged_in?
        # authors of topics don't get counted towards total hits
        @topic.hit! unless logged_in? and @topic.user == current_user
        @posts = @topic.posts.find(:all, :include => :user).paginate(:page => @page, :per_page => @per_page)
        #User.find(:all, :conditions => ['id IN (?)', @posts.collect { |p| p.user_id }.uniq]) unless @posts.blank?
        #@post = Post.new
        @page_title = @topic.title
        #@monitoring = logged_in? && !Monitorship.count(:id, :conditions => ['user_id = ? and topic_id = ? and active = ?', current_user.id, @topic.id, true]).zero?
        render_topic_view
      end
      format.xml do
        render :xml => @topic.to_xml
      end
      format.rss do
        @posts = @topic.posts.find(:all, :order => 'created_at desc', :limit => 25)
        render :action => 'show', :layout => false
      end
    end
  end
  
  def new
    @topic = Topic.new
    render_topic_view
  end
  
  def create
    # this is icky - move the topic/first post workings into the topic model?
    Topic.transaction do
      @topic = @forum.topics.build(params[:topic])
      assign_protected
      @post = @topic.posts.build(params[:topic])
      @post.topic = @topic
      @post.user = current_user
      # only save topic if post is valid so in the view topic will be a new record if there was an error
      @topic.body = @post.body # incase save fails and we go back to the form
      @topic.save! if @post.valid?
      @post.save! 
    end
    respond_to do |format|
      format.html { redirect_to get_topic_redirect }
      format.xml  { head :created, :location => formatted_forum_topic_url(:forum_id => @forum, :id => @topic, :format => :xml) }
    end
  end
  
  def edit
    render_topic_view
  end
  
  def update
    @topic.attributes = params[:topic]
    assign_protected
    @topic.save!
    respond_to do |format|
      format.html { redirect_to get_topic_redirect }
      format.xml  { head 200 }
    end
  end
  
  def destroy
    @topic.destroy
    flash[:notice] = _("Topic '%{title}' was deleted.") % {:title => @topic.title}
    respond_to do |format|
      format.html { redirect_to get_forum_redirect }
      format.xml  { head 200 }
    end
  end
  
  protected
    def assign_protected
      @topic.user = current_user if @topic.new_record?
      # admins and moderators can sticky and lock topics
      return unless admin? or current_user.moderator_of?(@topic.forum)
      @topic.sticky, @topic.locked = params[:topic][:sticky], params[:topic][:locked] 
      # only admins can move
      return unless admin?
      @topic.forum_id = params[:topic][:forum_id] if params[:topic][:forum_id]
    end
    
    def authorized?
      %w(new create).include?(action_name) || @topic.editable_by?(current_user)
    end
    
    def get_topic_redirect
      case @forum.forumable
      when Group
        group_forum_topic_path(@forum.forumable, @forum, @topic)
      else
        forum_topic_path(@forum, @topic)
      end
    end
    
    def render_topic_view
      case @forum.forumable
      when Group
        @group = @forum.forumable
        render :template => 'groups/topics/' + params[:action]
      else
        render
      end
    end
    
end
