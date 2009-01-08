class PostsController < ApplicationController
  
  include ForumMethods
  
  before_filter :find_forum
  before_filter :find_post,      :except => [:index, :new, :create, :monitored, :search]
  before_filter :login_required, :except => [:index, :monitored, :search, :show]
  @@query_options = { :select => "#{Post.table_name}.*, #{Topic.table_name}.title as topic_title, #{Forum.table_name}.name as forum_name", 
                      :joins => "inner join #{Topic.table_name} on #{Post.table_name}.topic_id = #{Topic.table_name}.id inner join #{Forum.table_name} on #{Topic.table_name}.forum_id = #{Forum.table_name}.id" }

  cache_sweeper :posts_sweeper, :only => [:create, :update, :destroy]

  def index
    conditions = []
    [:user_id, :forum_id, :topic_id].each { |attr| conditions << Post.send(:sanitize_sql, ["#{Post.table_name}.#{attr} = ?", params[attr]]) if params[attr] }
    conditions = conditions.empty? ? nil : conditions.collect { |c| "(#{c})" }.join(' AND ')
    @posts = Post.paginate @@query_options.merge(:conditions => conditions, :page => @page, :per_page => @per_page, :count => {:select => "#{Post.table_name}.id"}, :order => post_order)
    @users = User.find(:all, :select => 'distinct *', :conditions => ['id in (?)', @posts.collect(&:user_id).uniq]).index_by(&:id)
    render_posts_or_xml
  end

  def search		
    conditions = params[:q].blank? ? nil : Post.send(:sanitize_sql, ["LOWER(#{Post.table_name}.body) LIKE ?", "%#{params[:q]}%"])
    @posts = Post.paginate @@query_options.merge(:conditions => conditions, :page => @page, :per_page => @per_page, :count => {:select => "#{Post.table_name}.id"}, :order => post_order)
    @users = User.find(:all, :select => 'distinct *', :conditions => ['id in (?)', @posts.collect(&:user_id).uniq]).index_by(&:id)
    render_posts_or_xml :index
  end

  def monitored
    @user = User.find params[:user_id]
    options = @@query_options.merge(:conditions => ["#{Monitorship.table_name}.user_id = ? and #{Post.table_name}.user_id != ? and #{Monitorship.table_name}.active = ?", params[:user_id], @user.id, true])
    options[:order]  = post_order
    options[:joins] += " inner join #{Monitorship.table_name} on #{Monitorship.table_name}.topic_id = #{Topic.table_name}.id"
    options[:page]   = @page
    options[:count]  = {:select => "#{Post.table_name}.id"}
    @posts = Post.paginate options
    render_posts_or_xml
  end

  def show
    respond_to do |format|
      format.html { redirect_to forum_topic_path(@post.forum_id, @post.topic_id) }
      format.xml  { render :xml => @post.to_xml }
    end
  end

  def new
    find_topic
    @posts = @topic.posts.paginate :page => @page, :per_page => @per_page
    respond_to do |format| 
      format.html { render_post_view }
      format.js
    end
  end
  
  def create
    @topic = @forum.topics.find(params[:topic_id])
    if @topic.locked?
      respond_to do |format|
        format.html do
          flash[:notice] = _('This topic is locked.')
          redirect_to(forum_topic_path(:forum_id => params[:forum_id], :id => params[:topic_id]))
        end
        format.xml do
          render :text => _('This topic is locked.'), :status => 400
        end
      end
      return
    end
    @forum = @topic.forum
    @post  = @topic.posts.build(params[:post])
    @post.user = current_user
    @post.save!
    respond_to do |format|
      format.html do
        redirect_to get_post_redirect
      end
      format.xml { head :created, :location => formatted_post_url(:forum_id => params[:forum_id], :topic_id => params[:topic_id], :id => @post, :format => :xml) }
    end
  rescue ActiveRecord::RecordInvalid
    flash[:bad_reply] = _('Please post something at least...')
    respond_to do |format|
      format.html do
        redirect_to get_post_redirect
      end
      format.xml { render :xml => @post.errors.to_xml, :status => 400 }
    end
  end
  
  def edit
    respond_to do |format| 
      format.html { render_post_view }
      format.js
    end
  end
  
  def update
    @post.attributes = params[:post]
    @post.save!
  rescue ActiveRecord::RecordInvalid
    flash[:bad_reply] = _('An error occurred')
  ensure
    respond_to do |format|
      format.html do
        redirect_to get_post_redirect
      end
      format.js
      format.xml { head 200 }
    end
  end

  def destroy
    @post.destroy
    flash[:notice] = _("Post of '%{title}' was deleted.") % {:title => @post.topic.title}
    respond_to do |format|
      format.html { redirect_to get_post_redirect_for_delete }
      format.xml { head 200 }
    end
  end

  protected
    def authorized?
      action_name == 'create' || action_name == 'new' || @post.editable_by?(current_user)
    end
    
    def post_order
      "#{Post.table_name}.created_at#{params[:forum_id] && params[:topic_id] ? nil : " desc"}"
    end
    
    def render_posts_or_xml(template_name = action_name)
      respond_to do |format|
        format.html { render :action => template_name }
        format.rss  { render :action => template_name, :layout => false }
        format.xml  { render :xml => @posts.to_xml }
      end
    end
    
    def get_post_redirect_for_delete
      
      # make sure the topic wasn't deleted
      topic = Topic.find(@post.topic.id) rescue nil
      
      if topic
        case @forum.forumable
        when Group
          group_forum_topic_path(@forum.forumable, @forum, topic)
        else
          (@post.topic.frozen? ? 
            forum_path(params[:forum_id]) :
            forum_topic_path(:forum_id => params[:forum_id], :id => params[:topic_id], :page => @page, :per_page => @per_page))
        end
      else
        case @forum.forumable
        when Group
          group_forum_path(@forum.forumable, @forum)
        else
          forum_path(@forum)
        end
      end
      
    end
    
    def get_post_redirect
      case @forum.forumable
      when Group
        group_forum_topic_path(@forum.forumable, @forum, @post.topic, :anchor => @post.dom_id, :page => @page, :per_page => @per_page)
      else
        forum_topic_path(:forum_id => params[:forum_id], :id => params[:topic_id], :anchor => @post.dom_id, :page => @page, :per_page => @per_page)
      end
    end
    
    def render_post_view
      case @forum.forumable
      when Group
        @group = @forum.forumable
        render :template => 'groups/posts/' + params[:action]
      else
        render
      end
    end
end
