module ForumMethods

  protected

  def setup_show_forum
    # keep track of when we last viewed this forum for activity indicators
    (session[:forums] ||= {})[@forum.id] = Time.now.utc if logged_in?
    (session[:forum_page] ||= Hash.new(1))[@forum.id] = @page.to_i if @page
    @topics = @forum.topics.paginate :page => @page, :per_page => @per_page
    User.find(:all, :conditions => ['id IN (?)', @topics.collect { |t| t.replied_by }.uniq]) unless @topics.blank?
  end
  
  def find_forum
    @forum = Forum.find_by_url_key(params[:forum_id]) if params[:forum_id]
    @forum ||= Forum.find(params[:forum_id]) if params[:forum_id]
    @forum ||= Forum.find_by_url_key(params[:id]) if params[:id]
    @forum ||= Forum.find(params[:id]) if params[:id]
  end

  def find_topic
    @topic = @forum.topics.find(params[:id]) if params[:id]
    @topic ||= @forum.topics.find(params[:topic_id]) if params[:topic_id]
  end
  
  def find_post			
		@post = Post.find_by_id_and_topic_id_and_forum_id(params[:id], params[:topic_id], params[:forum_id]) || raise(ActiveRecord::RecordNotFound)
  end
  
  def get_forum_redirect
    case @forum.forumable
    when Group
      group_forum_path(@forum.forumable, @forum)
    else
      forum_path(@forum)
    end
  end
  
end