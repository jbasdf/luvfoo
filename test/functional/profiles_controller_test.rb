require File.dirname(__FILE__) + '/../test_helper'

class ProfilesControllerTest < Test::Unit::TestCase

  def setup
    @controller = ProfilesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  context "get index" do
    setup do
      get :index
    end

    should_respond_with :success
    should_render_template :index
  end

  context "get to show" do
    setup do
      @user = Factory(:user)
      Factory(:feed_item, :creator => @user)
      Factory(:feed_item, :creator => @user)
      get :show, :id => @user.to_param
    end

    should_respond_with :success
    should_render_template :show
  end
  
#  context 'on POST to :search' do
#    setup do
#      post :search, {:q => 'user'}
#    end
#
#    should_assign_to :results
#    should_respond_with :success
#    should_render_template :search
#  end
#
#  context 'on GET to :index' do
#    setup do
#      get :index
#    end
#
#    should_assign_to :results
#    should_respond_with :success
#    should_render_template :search
#  end
#
#  context 'on GET to :show while not logged in' do
#    setup do
#      get :show, {:id => users(:quentin).id}
#      assert_match "Sign-up to Follow", @response.body
#    end
#
#    should_assign_to :user
#    should_assign_to :profile
#    should_respond_with :success
#    should_render_template :show
#    should_not_set_the_flash
#  end
#
#  context 'on GET to :show.rss while not logged in' do
#    setup do
#      get :show, {:id => users(:quentin).id, :format=>'rss'}
#      assert_match "<rss version=\"2.0\">\n  <channel>\n    <title>#{GlobalConfig.application_name} Activity Feed</title>", @response.body
#    end
#
#    should_assign_to :user
#    should_assign_to :profile
#    should_respond_with :success
#    should_render_template :show
#    should_not_set_the_flash
#  end
#
#  context 'on GET to :edit while not logged in' do
#    setup do
#      get :edit, {:id => users(:quentin).id}
#    end
#
#    should_not_assign_to :user
#    should_respond_with :redirect
#    should_redirect_to 'login_path'
#    should_not_set_the_flash
#  end
#
#
#  context 'on GET to :show while logged in' do
#    setup do
#        get :show, {:id => users(:quentin).id}, {:user => users(:quentin).id}
#    end
#
#    should_assign_to :user
#    should_assign_to :profile
#    should_respond_with :success
#    should_render_template :show
#    should_not_set_the_flash
#  end
#
#  context 'on GET to :show while logged in as :user3' do
#    setup do
#      get :show, {:id => users(:quentin).id}, {:user => users(:friend_guy).id}
#      assert users(:friend_guy).followed_by?(users(:quentin))
#      assert_match "Be Friends", @response.body
#    end
#
#    should_assign_to :user
#    should_assign_to :profile
#    should_respond_with :success
#    should_render_template :show
#    should_not_set_the_flash
#  end
#
#  context 'on GET to :show while logged in as :user2' do
#    setup do
#      get :show, {:id => users(:friend_guy).id}, {:user => users(:aaron).id}
#      assert_match "Start Following", @response.body
#    end
#
#    should_assign_to :user
#    should_assign_to :profile
#    should_respond_with :success
#    should_render_template :show
#    should_not_set_the_flash
#  end
#
#
#  context 'on GET to :edit while logged in' do
#    setup do
#        get :edit, {:id => users(:quentin).id}, {:user => users(:quentin).id}
#      end
#
#    should_assign_to :user
#    should_assign_to :profile
#    should_respond_with :success
#    should_render_template :edit
#    should_render_a_form
#    should_not_set_the_flash
#  end  
#  
#  context 'rendering an avatar' do
#    
#    should 'use the user\'s icon if it exists' do
#      p =  users(:quentin)
#      p.icon = File.new(File.join(RAILS_ROOT, ['test', 'public','images','user.png']))
#      p.save!
#      #raise (p.send :icon_state).inspect
#      assert_not_nil p.icon
#      get :show, {:id => p.id, :public_view => true}, {:user => p.id}
#      assert_tag :img, :attributes => { :src => /\/system\/profile\/icon\/\d*\/big\/user.png/ }
#    end
#    
#    should 'use gravatar otherwise' do
#      p =  users(:aaron)
#      assert_nil p.icon
#      get :show, {:id => p.id}, {:user => p.id, :public_view => true}
#      assert_tag :img, :attributes => {:src => /www\.gravatar\.com/}
#    end
#    
#    should 'send the app\'s internal default as the default to gravatar' do
#      p =  users(:aaron)
#      assert_nil p.icon
#      get :show, {:id => p.id}, {:user => p.id, :public_view => true}
#      assert_tag :img, :attributes => { :src => /http...www.gravatar.com\/avatar\/[0-9a-f]+\?size\=50&amp;default\=http...test\.host\/images\/avatar_default_small\.png/ }
#    end
#  end
#
#
#  context 'on POST to :delete_icon' do
#    should 'delete the icon from the users profile' do
#      assert_not_nil users(:quentin).icon
#      post :delete_icon, {:id => users(:quentin).id, :format => 'js'}, {:user => users(:quentin).id}
#      assert_response :success
#      assert_nil assigns(:p).reload.icon
#    end
#  end
#
#
#  context 'on POST to :update' do
#    should 'update a user\'s profile with good data when logged in' do
#      assert_equal 'De', users(:quentin).first_name
#
#        post :update, {:id => users(:quentin).id, :user => {:email => 'user@example.com'}, :profile => {:first_name => 'Bob'}, :switch => 'name'}, {:user => users(:quentin).id}
#
#      assert_response :redirect
#      assert_redirected_to edit_profile_path(users(:quentin).reload)
#      assert_equal 'Settings have been saved.', flash[:notice]
#
#      assert_equal 'Bob', users(:quentin).reload.first_name
#    end
#
#    should 'not update a user\'s profile with bad data when logged in' do
#        post :update, {:id => users(:quentin).id, :profile => {:email => ''}, :switch => 'name'}, {:user => users(:quentin).id}
#
#      assert_response :success
#      assert_template 'edit'
#      assert_not_nil assigns(:profile).errors
#    end
#
#    should 'not update a user\'s profile without a switch' do
#      assert_equal 'De', users(:quentin).first_name
#
#        post :update, {:id => users(:quentin).id, :user => {:email => 'user@example.com'}, :profile => {:first_name => 'Bob'}}, {:user => users(:quentin).id}
#
#      assert_equal 'De', users(:quentin).first_name
#
#      assert_response :success
#    end
#
#    should 'update a user\'s password with good data when logged in' do
#      pass = users(:quentin).crypted_password
#
#        post :update, {:id => users(:quentin).id, :verify_password => 'test', :new_password => '1234', :confirm_password => '1234', :switch => 'password'}, {:user => users(:quentin).id}
#
#      assert_response :redirect
#      assert_redirected_to edit_profile_path(users(:quentin))
#      assert_equal 'Password has been changed.', flash[:notice]
#
#      assert_not_equal pass, assigns(:u).reload.crypted_password
#    end
#
#    should 'not update a user\'s password with bad data when logged in' do
#      pass = users(:quentin).crypted_password
#
#      post :update, {:id => users(:quentin).id, :verify_password => 'test', :new_password => '4321', :confirm_password => '1234', :switch => 'password'}, {:user => users(:quentin).id}
#
#      assert_response :success
#      assert_template 'edit'
#      assert_not_nil assigns(:user).errors
#    end
#
#  end
#
#
#  should "delete" do
#    assert_difference 'User.count', -1 do
#      assert users(:quentin)
#      delete :destroy, {:id=>users(:quentin).id}, {:user, users(:quentin).id}
#      assert_response 200
#      assert_nil User.find_by_id(users(:quentin).id)
#    end
#  end


end
