require File.dirname(__FILE__) + '/../../test_helper'

class Users::EventsControllerTest < ActionController::TestCase

  should_require_login :index

  context "logged in " do
    setup do
      @user = Factory(:user)
      login_as @user             
    end

    context "GET index (ics)" do
      setup do
        get :index, :user_id => @user.to_param, :format => 'ics' 
      end
      should_respond_with :success 
    end
    
  end


end