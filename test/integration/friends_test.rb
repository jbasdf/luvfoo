require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../integration/integration_helper"

class FriendsTest < ActionController::IntegrationTest

  include IntegrationHelper

  def test_aaron_follows_quentin
    Friend.destroy_all # clean out any existing relationships so there are no conflicts
    quentin = new_session_as(:quentin)
    aaron = new_session_as(:aaron)
    aaron.views_quentins_profile
    aaron.submits_friend_request(users(:quentin))
    quentin.sees_friend_request
  end 

  def test_quentin_befriends_aaron
    Friend.destroy_all # clean out any existing relationships so there are no conflicts
    quentin = new_session_as(:quentin)
    aaron = new_session_as(:aaron)
    quentin.views_aarons_profile
    quentin.submits_friend_request(users(:aaron))
    aaron.sees_friend_request
    aaron.accepts_friend_request(users(:quentin))
    quentin.sees_friend_request_was_successful(users(:aaron))
  end

  module FriendActions

    include IntegrationHelper::UserHelper

    def views_aarons_profile
      goes_to("/profiles/#{users(:aaron).to_param}", "profiles/show")
    end

    def views_quentins_profile
      goes_to("/profiles/#{users(:quentin).to_param}", "profiles/show")
    end

    def submits_friend_request(friend)          
      post user_friends_path(get_user, :id => friend)
      assert friend.followers.include?(get_user), "#{get_user.login} is not following #{friend.login}"
    end

    def sees_friend_request
      goes_to("/users/#{get_user.to_param}", "users/show")
      assert_select "a.notification-link", :text => '(ignore)' 
      assert_select "a.notification-link", :text => '(accept)'          
    end

    def accepts_friend_request(friend)
      post user_friends_path(get_user, :id => friend)
      is_redirected_to("profiles/show")
      assert_select "a", :text => 'Stop Being Friends' 
    end
    
    def sees_friend_request_was_successful(friend)
      goes_to("/profiles/#{friend.to_param}", "profiles/show")
      assert_select "a", :text => 'Stop Being Friends'
    end
    
    def get_user
      User.find(self.session[:user_id])
    end

  end

  def new_session
    open_session do |sess|
      sess.extend(FriendActions)
      yield sess if block_given?
    end
  end

end
