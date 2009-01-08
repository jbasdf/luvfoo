require File.dirname(__FILE__) + '/../test_helper'

class PasswordsControllerTest < ActiveSupport::TestCase

  fixtures :users

  def setup
    @controller = PasswordsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @emails     = ActionMailer::Base.deliveries
  end

  context "Not logged in" do

    context "Get new" do
      setup do
        get :new
      end
      should_not_set_the_flash
      should_respond_with :success
      should_render_template :new
    end

    context "reset password" do

      setup do
        user = Factory(:user)
        user.force_activate!
        @email = user.email
        @emails.clear
        post :create, :email => @email
      end

      should "send reset password email" do
        assert_sent_email do |email|
          email.subject =~ /You have requested to change your/ && 
          email.to.include?(@email)
        end
      end

      should_set_the_flash_to(/A password reset link has been sent to your email address/i) 
      should_redirect_to "login_path"

    end


    context "reset password for user that has not been activated" do
      setup do
        @user = Factory(:user)
        @email = @user.email
        @emails.clear
        post :create, :email => @email            
      end

      should "send reset notification email" do
        assert_sent_email do |email|
          email.subject =~ /not yet been activated/ &&
          email.to.include?(@email) &&
          email.body.include?("You requested that your #{GlobalConfig.application_name} password be reset") &&
          email.body.include?("http://#{GlobalConfig.application_url}/activate/#{@user.activation_code}")
        end
      end

      should_set_the_flash_to(/A password reset link has been sent to your email address/i)
      should_redirect_to "login_path"

    end

    context "don't reset password" do        
      setup do
        post :create, :email => 'bogus@example.com'
      end
      should_set_the_flash_to(/Could not find a user with that email address/i)
      should_respond_with :success
      should_render_template :new
    end

    context "get edit view without reset code" do
      setup do
        get :edit
      end
      should_not_set_the_flash
      should_respond_with :success
      should_render_template :new
    end

    context "get edit view" do
      setup do
        get :edit, :id => users(:quentin).password_reset_code
      end
      should_not_set_the_flash
      should_respond_with :success
      should_render_template :edit
    end

    context "don't update password - no password_reset_code" do
      setup do
        put :update
      end
      should_set_the_flash_to(/Could not find a password reset code.  Please try resetting your password again/i)
      should_respond_with :success
      should_render_template :new
    end

    context "don't update password - only id provided" do
      setup do
        put :update, :id => users(:quentin).password_reset_code
      end
      should_set_the_flash_to(/Password field cannot be blank/i)
      should_respond_with :success
      should_render_template :edit
    end

    context "don't update password - blank password" do
      setup do
        put :update, :password => {:password => ''}, :id => users(:quentin).password_reset_code
      end
      should_set_the_flash_to(/Password mismatch/)
      should_respond_with :success
      should_render_template :edit
    end

    context "update password with bad id" do
      setup do
        @quentin_id = users(:quentin).to_param
        put :update, :id => 'bad id', :password => 'newpassword', :password_confirmation => 'newpassword'
      end
      should_set_the_flash_to(/Sorry - That is an invalid password reset code/i)
      should_redirect_to "new_user_path"
    end

    context "update password - should be successful" do
      setup do
        @quentin_id = users(:quentin).to_param
        put :update, :id => users(:quentin).password_reset_code, :password => 'newpassword', :password_confirmation => 'newpassword'
      end
      should_set_the_flash_to(/Password reset/i)
      should_redirect_to "login_path"
    end

  end

  # If a user is logged in there is no need to reset their password
  # Test to ensure that the user is redirected 
  context "Logged in" do

    setup do
      login_as :quentin
    end

    context "on GET to new (reset password) while logged in" do
      setup do
        @quentin_id = users(:quentin).to_param
        get :new
      end
      should_not_set_the_flash
      should_redirect_to "user_url(@quentin_id)"
    end

    context "edit password" do
      setup do
        @quentin_id = users(:quentin).to_param
        get :edit
      end
      should_not_set_the_flash
      should_redirect_to "user_url(@quentin_id)"
    end

    context "update password" do
      setup do
        @quentin_id = users(:quentin).to_param
        put :update, :id => users(:quentin).password_reset_code, :password => 'new password'
      end
      should_not_set_the_flash
      should_redirect_to "user_url(@quentin_id)"
    end
  end

end