require 'md5'

module BeastHelper
  # convenient plugin point
  def head_extras
  end
	
	def count_for(title, count, suffix = '')
    number_with_delimiter(count) + ' ' + (count==1 ? title : title.pluralize) + suffix
  end
  
	def submit_tag(value = _("Save Changes"), options={} )
    or_option = options.delete(:or)
    return super + "<span class='button_or'>" + _("or") + " " + or_option + "</span>" if or_option
    super
  end

  def forum_link(forum)
    case forum.forumable
    when Group
      group_forum_path(forum.forumable, forum)
    else
      forum_path(forum)
    end
  end
  
  def post_link(post)    
    forum = post.forum
    case forum.forumable
    when Group
      group_forum_topic_path(forum.forumable, forum, post.topic, :anchor => post.dom_id)
    else
      forum_topic_path(forum, post.topic, :anchor => post.dom_id)
    end    
  end
  
  def ajax_spinner_for(id, spinner="spinner.gif")
    "<img src='/images/#{spinner}' style='display:none; vertical-align:middle;' id='#{id.to_s}_spinner'> "
  end

  def feed_icon_tag(title, url)
    (@feed_icons ||= []) << { :url => url, :title => title }
    link_to image_tag('feed-icon.png', :size => '14x14', :style => 'margin-right:5px', :alt => "Subscribe to #{title}"), url
  end

  def search_posts_title
    returning(params[:q].blank? ? _('Recent Posts') : _("Searching for") + " '#{h params[:q]}'") do |title|
      title << " " + _('by %{user}') % {:user => h(User.find(params[:user_id]).display_name)} if params[:user_id]
      title << " " + _('in %{forum}') % {:forum => h(Forum.find(params[:forum_id]).name)} if params[:forum_id]
    end
  end

  def topic_title_link(topic, options)
    if topic.title =~ /^\[([^\]]{1,15})\]((\s+)\w+.*)/
      "<span class='flag'>#{$1}</span>" + 
      link_to(h($2.strip), forum_topic_path(@forum, topic), options)
    else
      link_to(h(topic.title), forum_topic_path(@forum, topic), options)
    end
  end

  def search_posts_path(rss = false)
    options = params[:q].blank? ? {} : {:q => params[:q]}
    prefix = rss ? 'formatted_' : ''
    options[:format] = 'rss' if rss
    [[:user, :user_id], [:forum, :forum_id]].each do |(route_key, param_key)|
      return send("#{prefix}#{route_key}_posts_path", options.update(param_key => params[param_key])) if params[param_key]
    end
    options[:q] ? search_all_posts_path(options) : send("#{prefix}all_posts_path", options)
  end

end
