require File.dirname(__FILE__) + '/../../test_helper'

class Admin::HomeControllerTest < ActionController::TestCase

  def setup
    @controller =  Admin::HomeController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  should_require_login :index, :show, :new, :create, :edit, :update, :destroy

  context "logged in as user" do
    setup do
      login_as users(:aaron).login
    end
  end

  context "logged in as admin" do
    setup do
      login_as :admin
    end

    context "GET index" do
      setup do
        get :index
      end
      should_respond_with :success
      should_render_template :index
    end
  end

end
