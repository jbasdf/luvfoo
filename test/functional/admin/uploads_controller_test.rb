require File.dirname(__FILE__) + '/../../test_helper'

class Admin::UploadsControllerTest < ActionController::TestCase

  should_require_login :index

  context "logged in as admin" do
    setup do
      login_as :admin
    end

    context "GET files (js)" do
      setup do
        get :files, { :format => 'js' }
      end
      should_respond_with :success
    end

    context "GET images (js)" do
      setup do
        get :images, { :format => 'js' }
      end
      should_respond_with :success
    end
    
  end

end
