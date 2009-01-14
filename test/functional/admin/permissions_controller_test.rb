require File.dirname(__FILE__) + '/../../test_helper'

class Admin::PermissionsControllerTest < ActionController::TestCase

  def setup
    @controller =  Admin::PermissionsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  should_require_login :create, :destroy 

  context "logged in as admin" do
    setup do
      login_as :admin
    end

    context "POST create" do
      setup do
        user = Factory(:user)
        role = Factory(:role)
        post :create, :login => user.login, :role_id => role.id
      end
      should_redirect_to "admin_roles_path"
    end
    
    context "POST create js" do
      setup do
        @user = Factory(:user)
        @role = Factory(:role)
      end
      
      should "create a new permission" do
        assert_difference "Permission.count", 1 do
          post :create, { :login => @user.login, :role_id => @role.id, :format => 'js' }
        end
      end
      
    end
    
    context "DELETE destroy" do
      setup do
        permission = Factory(:permission)
        delete :destroy, :id => permission.id
      end
      should_redirect_to "admin_roles_path"
    end

    context "DELETE destroy js" do
      setup do
        @permission = Factory(:permission)        
      end
      should "delete permission" do
        assert_difference "Permission.count", -1 do
          delete :destroy, :id => @permission.id
        end
      end
    end
    
  end

end
