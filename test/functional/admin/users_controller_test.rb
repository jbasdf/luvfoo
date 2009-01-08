require File.dirname(__FILE__) + '/../../test_helper'

class Admin::UsersControllerTest < ActionController::TestCase

  def setup
    @controller =  Admin::UsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @user       = users(:quentin)
  end

  should_require_login :index, :show, :new, :create, :edit, :update, :destroy

  context "logged in as user" do
    setup do
      login_as users(:aaron).login
    end
    should_require_login :index, :show, :new, :create, :edit, :update, :destroy
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

    context "GET inactive" do
      setup do
        get :inactive
      end
      should_respond_with :success
      should_render_template :inactive
    end
    
    context "GET search" do
      setup do
        get :search
      end
      should_respond_with :success
      should_render_template :search
    end
    
    # TODO get user delete working
    # context 'on DELETE to :destroy' do
    #   setup do
    #     delete :destroy, {:id => @user.to_param}
    #   end
    #   should_redirect_to "admin_users_path"
    #   should_set_the_flash_to(/successfully deleted/i)
    # end

  end

end
