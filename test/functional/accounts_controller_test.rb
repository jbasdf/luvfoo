require File.dirname(__FILE__) + '/../test_helper'

class AccountsControllerTest < ActionController::TestCase

  fixtures :users

  def setup
    @controller = AccountsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  context "not logged in" do

    context "activate user" do
      setup do                
        get :show, :id => users(:not_activated_user).activation_code
      end
      should_set_the_flash_to(/Your account has been activated! You can now login/i)
      should_redirect_to 'login_path' 
      should "be able to login" do
        assert_equal users(:quentin), User.authenticate('quentin', 'test')
      end            
    end

    context "attempt to activate already activated user" do
      setup do                
        get :show, :id => users(:quentin).activation_code
      end
      should_set_the_flash_to(/Your account has already been activated. You can log in below/i)
      should_redirect_to 'login_path'             
    end

    context "on GET edit" do
      setup do
        get :edit
      end
      should_redirect_to "login_url"
    end

    context "don't activate user without key" do
      setup do
        get :show
      end
      should_set_the_flash_to(/Activation code not found. Please try creating a new account/i)
      should_redirect_to "new_user_path"
    end

    context "don't activate user with blank key" do
      setup do
        get :show, :id => ''
      end
      should_set_the_flash_to(/Activation code not found. Please try creating a new account/i)
      should_redirect_to "new_user_path"
    end

    context "don't activate user with bad key" do
      setup do
        get :show, :id => 'asdfasdfasdf'
      end
      should_set_the_flash_to(/Activation code not found. Please try creating a new account/i)
      should_redirect_to "new_user_path"
    end

    context "attempt to change password" do
      setup do
        update_password
      end
      should_redirect_to "login_url"
    end

  end

  context "logged in" do

    setup do
      @user = users(:quentin)
      login_as :quentin
    end

    context "attempt to change password with incorrect old password" do
      setup do
        update_password :old_password => 'wrong', :password => '', :password_confirmation => ''
      end
      should_set_the_flash_to(/Your old password is incorrect/i)
      should_redirect_to "edit_user_path(@user)"  
    end

    context "attempt to change password with blank password" do
      setup do
        update_password :password => '', :password_confirmation => ''
      end
      should_set_the_flash_to(/password does not match the password confirmation/i)
      should_redirect_to "edit_user_path(@user)"        
    end

    context "attempt to change password with invalid password" do
      setup do
        update_password :password => '123', :password_confirmation => '123'
      end
      should_set_the_flash_to(/Password is too short/i)
      should_redirect_to "edit_user_path(@user)"       
    end

    context "change password" do
      setup do
        @quentin = users(:quentin)
        update_password
      end
      should_set_the_flash_to(/Password successfully updated/i)
      should_redirect_to "edit_user_path(@quentin)"  
    end

  end

  protected 

  def update_password(options = {})
    post :update, {:old_password => 'test', 
      :password => 'newtest', 
      :password_confirmation => 'newtest'}.merge(options)
    end

  end