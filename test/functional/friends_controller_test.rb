require File.dirname(__FILE__) + '/../test_helper'

class FriendsControllerTest < ActionController::TestCase

  def setup
    @controller = FriendsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @user       = users(:quentin)
  end

  context "not logged in" do

    context 'render index page' do
      setup do
        get :index, :user_id => users(:quentin).to_param
      end
      should_respond_with :success
      should_render_template :index
    end

    context "deny access to create" do
      setup do
        post :create, { :user_id => users(:aaron).to_param }
      end
      should_redirect_to "login_path"
      should_set_the_flash_to(NOT_LOGGED_IN_MSG)
    end

    context "deny access to destroy" do
      setup do
        delete :destroy, { :user_id => users(:aaron).to_param }
      end
      should_redirect_to "login_path"
      should_set_the_flash_to(NOT_LOGGED_IN_MSG)
    end

  end

  context "logged in" do

    setup do
      login_as :quentin
    end

    context 'render my index page' do
      setup do
        get :index, :user_id => users(:quentin).to_param
      end
      should_respond_with :success
      should_render_template :index
    end

    context "render another user's friend page" do
      setup do
        get :index, :user_id => users(:aaron).to_param
      end
      should_respond_with :success
      should_render_template :index
    end

    context "make a follower (same as send friend request)" do
      setup do
        Friend.destroy_all
        post :create, { :id => users(:aaron).to_param, :format=>'js' }
      end

      should_respond_with :success
      should_not_set_the_flash

      should "setup relationship" do
        users(:quentin).reload
        users(:aaron).reload

        assert !users(:quentin).friend_of?(users(:aaron))
        assert users(:quentin).following?(users(:aaron))
        assert users(:aaron).followed_by?(users(:quentin))
      end
    end

    context "make a friendship" do
      setup do
        Friend.destroy_all
        Friend.make_friends users(:quentin), users(:aaron)
        post :create, { :id => users(:aaron).to_param, :format=>'js'}
      end

      should_respond_with :success
      should_not_set_the_flash

      should "setup friend relationship" do
        users(:quentin).reload
        users(:aaron).reload

        assert users(:quentin).friend_of?(users(:aaron))
        assert !users(:quentin).followed_by?(users(:aaron))
        assert users(:aaron).friend_of?(users(:quentin))
        assert !users(:aaron).followed_by?(users(:quentin))
      end
    end

    context "error while trying to make an invalid friendship" do
      setup do
        Friend.destroy_all
        post :create, { :id => users(:quentin).to_param, :format => 'js' }
      end

      should_respond_with :success
      should_not_set_the_flash

      should "not create friendship" do
        users(:quentin).reload
        users(:aaron).reload
      end
    end

    context 'stop following (same as deleting a friend request if following is not allowed)' do
      setup do
        Friend.destroy_all
        Friend.make_friends users(:quentin), users(:aaron)
        delete :destroy, { :user_id => users(:quentin).to_param, :id => users(:aaron).to_param, :format=>'js'}
      end

      should_respond_with :success

      should "stop following (delete friend request)" do
        users(:quentin).reload
        users(:aaron).reload

        assert !users(:quentin).following?(users(:aaron))
      end
    end

    context "Following allowed" do

      setup do
        GlobalConfig.allow_following = true
      end

      context 'stop being friends' do
        setup do
          Friend.destroy_all
          Friend.make_friends users(:quentin), users(:aaron)
          Friend.make_friends users(:aaron), users(:quentin)
          delete :destroy, { :user_id => users(:quentin).to_param, :id => users(:aaron).to_param, :format=>'js'}
        end

        should_respond_with :success

        should "stop being friends" do
          users(:quentin).reload
          users(:aaron).reload

          assert !users(:quentin).friend_of?(users(:aaron))
          assert !users(:quentin).following?(users(:aaron))
          assert users(:quentin).followed_by?(users(:aaron))
        end
      end
    end
    
    context "Following not allowed (friend requests only)" do

      setup do
        GlobalConfig.allow_following = false
      end

      context 'stop being friends' do
        setup do
          Friend.destroy_all
          Friend.make_friends users(:quentin), users(:aaron)
          Friend.make_friends users(:aaron), users(:quentin)
          delete :destroy, { :user_id => users(:quentin).to_param, :id => users(:aaron).to_param, :format=>'js'}
        end

        should_respond_with :success

        should "stop being friends" do
          users(:quentin).reload
          users(:aaron).reload

          assert !users(:quentin).friend_of?(users(:aaron))
          assert !users(:quentin).following?(users(:aaron))
          assert !users(:quentin).followed_by?(users(:aaron))
        end
      end
      
    end
    
  end
end