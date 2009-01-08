module FriendsHelper

  def get_friend_link user, target
    
    return wrap_get_friend_link(link_to( _('Sign-up to Follow'), signup_path)) if user.blank?
    return '' unless user != :false && target
    
    dom_id = make_id(user, target)
    
    return wrap_get_friend_link('') if user == target
    
    return wrap_get_friend_link(link_to_remote( _('Stop Being Friends'), :url => user_friend_path(user, target), :method => :delete), dom_id) if user.friend_of? target
    
    if GlobalConfig.allow_following
      return wrap_get_friend_link(link_to_remote( _('Stop Following'), :url => user_friend_path(user, target), :method => :delete), dom_id) if user.following? target
    else
      if user.following? target
        return wrap_get_friend_link( _("Friend request pending %{link}") % {:link => link_to_remote( _('(delete)'), :url => user_friend_path(user, target), :method => :delete)}, dom_id)
      end
    end
    
    return wrap_get_friend_link(link_to_remote( _('Accept Friend Request'), :url => user_friends_path(user, :id => target), :method => :post), dom_id) if user.followed_by? target
    
    if GlobalConfig.allow_following
      wrap_get_friend_link(link_to_remote( _('Start Following'), :url => user_friends_path(user, :id => target), :method => :post), dom_id)
    else
      wrap_get_friend_link(link_to_remote( _('Friend Request'), :url => user_friends_path(user, :id => target), :method => :post), dom_id)
    end
    
  end

  def accept_follower_link user, target
    dom_id = make_id(user, target)
    wrap_get_friend_link(link_to_remote( _('(accept)'), { :url => user_friends_path(user, :id => target), :method => :post}, {:id => "accept-#{target.id}", :class => 'notification-link'}), dom_id)
  end

  def ignore_friend_request_link user, target
    dom_id = make_id(user, target)
    wrap_get_friend_link(link_to_remote( _('(ignore)'), { :url => user_friend_path(user, target), :method => :delete }, {:id => "ignore-#{target.id}", :class => 'notification-link'}), dom_id)
  end

  protected
  def wrap_get_friend_link str, dom_id = ''
    content_tag :span, str, :id => dom_id, :class => 'friendship_description'
  end

  def make_id user, target
    user.dom_id(target.dom_id + '_friendship_')
  end
    
end