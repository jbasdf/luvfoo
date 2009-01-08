require File.dirname(__FILE__) + '/../../test_helper'

class Groups::MembershipsControllerTest < Test::Unit::TestCase

  def setup
    @controller = Groups::MembershipsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @group      = groups(:africa)
    @membership = memberships(:africa_member)
  end

  def self.should_get_index
    context "GET index page" do
      setup do
        get :index, { :group_id => groups(:africa).to_param }
      end

      should_respond_with :success
      should_render_template :index
      should_not_set_the_flash
    end
  end

  def self.should_leave_group
    context 'DELETE to :destroy - leave group' do
      setup do
        delete :destroy, { :group_id => groups(:africa).to_param }
      end

      should_respond_with :success
      should_render_template "groups/_join_controls"
    end
  end

  def self.should_join_group
    
    context "POST to create - join group" do
      setup do
        post :create, { :group_id => groups(:africa).to_param }
      end      
      should_redirect_to "group_path(@group)"
      should_set_the_flash_to(/You have joined the group/i)
    end
    
    context "POST to create - join group (js)" do
      setup do
        post :create, { :group_id => groups(:africa).to_param, :format => 'js' }
      end
      should_respond_with :success
      should_render_template "groups/_member_controls"
      should_not_set_the_flash
    end
    
  end

  def self.should_not_rejoin_group
    
    context "POST to create - join group" do
      setup do
        post :create, { :group_id => groups(:africa).to_param }
      end      
      should_redirect_to "group_path(@group)"
      should_set_the_flash_to(/You are already a member of/i)
    end
    
    context "POST to create - join group (js)" do
      setup do
        post :create, { :group_id => groups(:africa).to_param, :format => 'js' }
      end
      should_respond_with :success
      should_render_template "groups/_member_controls"
      should_not_set_the_flash
    end
    
  end
  
  context 'anonymous user' do
  
    should_get_index
  
    context "attempts to join " do
      setup do
        post :create, { :group_id => groups(:africa).to_param }
      end
  
      should_set_the_flash_to(/You must be logged in to access this feature/i)
      should_redirect_to "login_path"
    end
  
    context "attempts to join (js)" do
      setup do
        post :create, { :group_id => groups(:africa).to_param, :format => 'js' }
      end
      should_not_set_the_flash
      should_respond_with 406
    end
    
    context "attempts to leave " do
      setup do
        delete :destroy, { :group_id => groups(:africa).to_param }
      end
      should_set_the_flash_to(/You must be logged in to access this feature/i)
      should_redirect_to "login_path"
    end
  
    context "attempts to leave (js)" do
      setup do
        delete :destroy, { :group_id => groups(:africa).to_param, :format => 'js' }
      end
      should_not_set_the_flash
      should_respond_with 406
    end
    
    context "attempt to join invisible group" do
      setup do
        get :new, { :group_id => groups(:invisible).to_param }
      end
      should_set_the_flash_to(/You must be logged in to access this feature/i)
      should_redirect_to "login_path"
    end
    
  end

  context 'logged in as group member' do
    setup do
      login_as :africa_member
    end
    
    should_get_index
    should_leave_group
    should_not_rejoin_group
  end
  
  context 'logged in as group creator' do
    setup do
      login_as :quentin
    end
  
    should_get_index
    should_leave_group
    should_not_rejoin_group
  end

  context 'logged in as admin' do
    setup do
      login_as :admin
    end

    should_get_index
    should_join_group
    should_leave_group
  end

  context 'logged in as non group member' do
    setup do
      login_as :aaron
    end
  
    context "attempt to join invisible group" do
      setup do
        get :new, { :group_id => groups(:invisible).to_param }
      end
      
      should_respond_with :success
      should_render_template "new"
      should_not_set_the_flash
      
    end
    
    should_get_index
    should_join_group
    should_leave_group
  end

end
