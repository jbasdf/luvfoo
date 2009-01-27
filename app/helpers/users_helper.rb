require 'avatar/view/action_view_support'

module UsersHelper

  include Avatar::View::ActionViewSupport

  def location_link user = current_user
    return user.location if user.location == 'No Where'
    link_to h(user.location), search_profiles_path.add_param('search[location]' => user.location)
  end

  def user_has_grade_level_experience?(level)
    if @user && !@user.login.nil? # no sense in testing new users that have no grade levels
      @user_grade_level_experience_ids ||=  @user.grade_level_experiences.collect{|c| c.id}
      @user_grade_level_experience_ids.include?(level.id)
    else
      false
    end
  end

  def user_speaks_language?(language)
    if @user && !@user.login.nil? # no sense in testing new users that have no languages
      @user_language_ids ||= @user.languages.collect{|c| c.id}
      @user_language_ids.include?(language.id)
    else
      false
    end
  end

  def user_has_interest?(interest)
    if @user && !@user.login.nil? # no sense in testing new users that have no interests
      @user_interest_ids ||= @user.interests.collect{|c| c.id}
      @user_interest_ids.include?(interest.id)
    else
      false
    end
  end

  def is_group_share_checked?(group, group_id)
    if group["shared"] && group.shared == "t"
      'disabled="true" checked="checked"' 
    elsif @group_id == group.id
      'checked="checked"' 
    end
  end

  def is_profile_empty?
    photos_empty = current_user.photos.empty?
    friends_empty = (current_user.followings + current_user.friends).empty?
    messages_empty = current_user.sent_messages.empty?
    blog_empty = current_user.blogs.empty?

    photos_empty && friends_empty && messages_empty && blog_empty
  end

  def pledge_admin_links pledge
    dom_id = "group_pledge_#{pledge.membership_request_id}"
    links = accept_pledge_link(pledge, dom_id) + ' ' + decline_pledge_link(pledge, dom_id)
    wrap_pledge_link(links, dom_id)
  end
  
  def accept_pledge_link pledge, dom_id
    link_to_remote( _('(accept)'), :url => group_memberships_path(pledge.url_key, :user_id => pledge.id), :method => :post, :update => dom_id)
  end

  def decline_pledge_link pledge, dom_id
    inline_tb_link _('(decline)'), 'decline_request_to_join', {:title => _('Decline Request to Join Group'), :onclick => "jQuery('#name').val('#{pledge.full_name}');jQuery('#message_receiver_id').val('#{pledge.id}');jQuery('#membership_request_id').val('#{pledge.membership_request_id}');jQuery('#message_subject').val('Request to join #{h(pledge.group_name)} is denied');"}, {:width => 500, :height => 340}
  end
  
  def wrap_pledge_link str, dom_id = ''
    content_tag :span, str, :id => dom_id, :class => 'pledge_description'
  end
  
  def is_profile_item_visible name
    p = @user.property(name)
    visibility = !p ? BagProperty::VISIBILITY_FRIENDS : p.visibility.to_i
    return true if visibility == BagProperty::VISIBILITY_EVERYONE
    return false if !logged_in?
    return true if visibility == BagProperty::VISIBILITY_USERS
    return true if visibility == BagProperty::VISIBILITY_FRIENDS && @user.friend_of?(current_user)
    return true if is_admin?
    return false
 end
  
end
