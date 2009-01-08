require File.dirname(__FILE__) + '/../test_helper'

class UsersControllerTest < Test::Unit::TestCase

  def setup
    @controller = UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  context "automatically activate account and log user in. " do
    setup do
      GlobalConfig.automatically_activate = true
      GlobalConfig.automatically_login_after_account_create = true
    end

    context "on POST to :create" do

      setup { post_create_user }                                
      should_redirect_to "edit_user_path(@user, :fv => true)"

      should "reset global settings" do
        GlobalConfig.automatically_activate = false
        GlobalConfig.automatically_login_after_account_create = false
      end

    end
    
  end

  context "automatically activate account do not log user in" do
    setup do
      GlobalConfig.automatically_activate = true
      GlobalConfig.automatically_login_after_account_create = false
    end
  
    context "on POST to :create" do
  
      setup { post_create_user }                                
      should_redirect_to "login_path" 
      should_set_the_flash_to(/you may login/i)
  
      should "reset global settings" do
        GlobalConfig.automatically_activate = false
      end
  
    end
    
    context "on POST to :create with bad login (space in login name)" do
  
      setup { post_create_user(:login => 'test guy') }                                
      should_respond_with :success
      should_render_template :new
  
      should "assign an error to the login field" do
        assert assigns(:user).errors.on(:login) 
      end
  
    end
    
  end
  
  context "do not auto activate.  do not login after create" do
    setup do
      GlobalConfig.automatically_activate = false
      GlobalConfig.automatically_login_after_account_create = false
    end
  
    context "on POST to :create -- Allow signup. " do
      setup do
        post_create_user
      end                                
      should_redirect_to "welcome_user_path(@user)" 
      should_set_the_flash_to(/check your email to activate your account/i)
    end
  
    context "on POST to :create -- require login on signup. " do
      setup do
        post_create_user :login => ''
      end
  
      should_respond_with :success
      should_render_template :new
      should "assign an error to the login field" do
        assert assigns(:user).errors.on(:login) 
      end                                       
    end
  
    context "on POST to :create with bad login (space in login name)" do
  
      setup { post_create_user(:login => 'test guy') }                                
      should_respond_with :success
      should_render_template :new
  
      should "assign an error to the login field" do
        assert assigns(:user).errors.on(:login) 
      end
  
    end
    
    context "on POST to :create -- require password on signup. " do
      setup { post_create_user :password => nil }
      should_respond_with :success
      should_render_template :new
      should "assign an error to the password field" do
        assert assigns(:user).errors.on(:password) 
      end                                       
    end
  
    context "on POST to :create -- require password confirmation on signup. " do
      setup { post_create_user :password_confirmation => nil }
      should_respond_with :success
      should_render_template :new
  
      should "assign an error to the password confirmation field" do
        assert assigns(:user).errors.on(:password_confirmation) 
      end                                       
    end
  
    context "on POST to :create -- require email on signup. " do
      setup { post_create_user :email => nil }
      should_respond_with :success
      should_render_template :new
      should "assign an error to the email field" do
        assert assigns(:user).errors.on(:email) 
      end                                       
    end
  end
  
  context "on GET to :index" do
    setup { get :index }
    should_redirect_to "profiles_url"
  end
  
  context "on GET to :help" do
    setup { get :help, :id => users(:quentin).login }
    should_respond_with :success
    should_render_template :help
  end    
  
  context "on GET to :welcome" do
    setup { get :welcome, :id => users(:quentin).login }
    should_respond_with :success
    should_render_template :welcome
  end
  
  context "on GET to new (signup)" do
    setup do
      @quentin = users(:quentin)
      login_as :quentin 
      get :new
    end
    should_redirect_to "user_url(@quentin)"
  end
  
  context "on GET to edit (preferences) not logged in" do
    setup do
      get :edit, :id => users(:quentin)
    end
    should_redirect_to "login_url"
  end
  
  context "on GET to edit (preferences) logged in" do
    setup do
      login_as :quentin
      get :edit, :id => users(:quentin).login
    end
    should_respond_with :success
    should_render_template :edit
  end

  context "on GET to edit (preferences) logged in but wrong user" do
    setup do
      @follower_guy = users(:follower_guy)
      login_as :follower_guy
      get :edit, :id => users(:aaron).login
    end
    should_redirect_to "user_url(@follower_guy)"
  end

  def post_create_user(options = {})
    post :create, 
    :user => { :login => 'testguy', 
      :email => rand(1000).to_s + 'testguy@example.com', 
      :password => 'testpasswrod', 
      :password_confirmation => 'testpasswrod', 
      :language_id => languages(:english).id, 
      :language_ids => [languages(:english).id, languages(:japanese).id, languages(:tonga).id],
      :country_id => countries(:usa),
      :first_name => 'Ed',
      :last_name => 'Decker',
      :grade_level_experience_ids => [grade_level_experiences(:college), grade_level_experiences(:first), grade_level_experiences(:high_school)],
      :terms_of_service => true }.merge(options)
    end
  end