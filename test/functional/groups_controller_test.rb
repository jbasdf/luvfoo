require File.dirname(__FILE__) + '/../test_helper'

class GroupsControllerTest < Test::Unit::TestCase

  def setup
    @controller = GroupsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @group      = groups(:africa)
    @africa     = groups(:africa)
    @invisible  = groups(:invisible)
  end

  should_require_login :new, :create, :edit, :update, :destroy
  
  def self.should_deny_group_admin_actions(name)

    context "deny access to admin actions" do

      setup do
        @group_to_test = self.instance_variable_get("@#{name.to_s}")
      end

      should "now allow edit" do
        get :edit, :id => @group_to_test.to_param
        assert_redirected_to group_url(@group_to_test)
        ensure_flash(PERMISSION_DENIED_MSG)
      end

      should "not allow update" do
        put :update, :id => @group_to_test.to_param
        assert_redirected_to group_url(@group_to_test)
        ensure_flash(PERMISSION_DENIED_MSG)
      end

      should "not allow destroy" do
        delete :destroy, :id => @group_to_test.to_param
        assert_redirected_to group_url(@group_to_test)
        ensure_flash(PERMISSION_DENIED_MSG)
      end

    end

  end

  context "not logged in" do

    context "view normal group" do
      setup do
        get :show, :id => groups(:africa).to_param
      end
      should_respond_with :success
      should_render_template :show
    end
    
    context "view invisible group" do
      setup do
        get :show, :id => groups(:invisible).to_param
      end
      should_redirect_to "groups_path"
    end

    context "view private group" do
      setup do
        get :show, :id => groups(:private).to_param
      end
      should_respond_with :success
      should_render_template :show
      should "show group information" do
        assert_select "#information", :count => 1
      end
      should "not show group officers" do
        assert_select "#group-officers", :count => 0
      end
    end

    context "get index page" do
      setup do
        get :index
      end
      should "not show invisible groups" do
        # check the page to make sure the invisible group isn't there
        # assert_select ".invisible", :count => 0
      end
    end
  end

  context "logged in, not a member" do

    setup do
      login_as users(:aaron)
      @group = groups(:invisible)
    end

    should_deny_group_admin_actions(:africa)
    should_deny_group_admin_actions(:invisible)

    context "view invisible group" do
      setup do
        get :show, :id => @group.to_param
      end
      should_redirect_to "groups_path"
    end
  end

  context "logged in member - not manager or admin" do

    setup do
      login_as users(:africa_member)
      @group = groups(:africa)
    end        

    should_deny_group_admin_actions(:africa)
    should_deny_group_admin_actions(:invisible)

    context "view invisible group" do
      setup do
        login_as users(:invisible_member)
        get :show, :id => groups(:invisible).to_param
      end
      should_respond_with :success
      should_render_template :show
    end

  end

  context "logged in manager" do

    setup do
      @admin_user = users(:admin)
      login_as @admin_user
    end        

    should_be_restful do |resource|
      resource.actions    = [:index, :show, :edit, :update]
      resource.formats    = [:html]
      resource.create.params = { :name => "a random new group", :description => 'this is the random group', :default_role => 'member'}
      resource.update.params = { :name => "Changed", :description => 'this is the changed, random group' }    
    end

    context "show the group" do
      setup do
        get :show, :id => groups(:africa).to_param
      end

      should_respond_with :success
      should_render_template :show

      should "have a join link since admin isn't a member" do
        assert_select "div#join_group"
        assert_select "a", :text => "Join #{groups(:africa).name}"
      end

    end

    context "update group" do
      setup do
        @new_group_name = 'new group name asdf'
        @new_description = 'new group description'
        put :update, :id => @group.to_param, :group => { :name => @new_group_name, :description => @new_description }
      end

      should_redirect_to "group_path(@group)"
      should_set_the_flash_to(/Group was successfully updated/i)

      should "have new values" do
        @group.reload
        assert @group.name == @new_group_name
        assert @group.description == @new_description
      end

    end        

    should "not delete group only mark it 'deleted'" do
      assert_no_difference "Group.count" do
        group = Factory(:group, :creator => @admin_user)
        delete :destroy, { :id => group.to_param }
        assert_redirected_to groups_url
        group.reload
        assert group.visibility == Group::DELETED
      end
    end
    
  end

end