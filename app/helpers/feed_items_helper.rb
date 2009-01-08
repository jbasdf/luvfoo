module FeedItemsHelper

  def x_feed_link(feed_item)
    '<a id="feed_item_' + feed_item.id.to_s + '" href="#" class="activity-delete">' + 
      image_tag('delete.png', :class => 'png', :width => '10', :height => '10') + '</a>'
  end

  def commentable_text(comment, in_html = true)
    return '' if comment.user.nil?
    comment_activity = render_comment(comment, in_html) 
    if comment_activity
      comment_activity + ': <br /><span class="activity-comment">' + comment.comment + '</span>' 
    else
      ''
    end
  end

private  
  def render_comment(comment, in_html)
    parent = comment.commentable
    case parent.class.name
    when 'User'
      "#{link_to_if in_html, comment.user.full_name, profile_path(comment.user)} 
      wrote a comment on #{link_to_if in_html, parent.full_name + '\'s', profile_path(parent)} wall"
    when 'Blog'
      "#{link_to_if in_html, comment.user.full_name, profile_path(comment.user)} 
      commented on #{link_to_if in_html, h(parent.title), profile_blog_path(parent.user, parent)}"
    when 'Group'
      "#{link_to_if in_html, comment.user.full_name, profile_path(comment.user)} 
      commented on #{link_to_if in_html, h(parent.name), group_path(parent)}"
    when 'NewsItem'
      case parent.newsable_type
      when 'Group'
        "#{link_to_if in_html, comment.user.full_name, profile_path(comment.user)} 
        commented on #{link_to_if in_html, h(parent.title), group_news_path(parent.newsable, parent)}"
      when 'User'
        return
        "#{link_to_if in_html, comment.user.full_name, profile_path(comment.user)} 
        commented on #{link_to_if in_html, h(parent.title), profile_blog_path(parent.newsable, parent)}"
      else # 'Site', 'Widget'
        "#{link_to_if in_html, comment.user.full_name, profile_path(comment.user)} 
        commented on #{link_to_if in_html, h(parent.title), member_story_path(parent)}"  
      end
    else
      ''
    end
  end
  
end
