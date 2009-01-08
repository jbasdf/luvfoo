require File.dirname(__FILE__) + '/../../test_helper'

class Users::GroupsControllerTest < Test::Unit::TestCase

  def setup
    @controller = Users::GroupsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @group      = groups(:africa)
    @user       = users(:quentin)
  end

  context "not logged in" do

    should_be_restful do |resource|
      resource.parent     = @user
      resource.klass      = Group
      resource.object     = :group
      resource.actions    = [:index, :show, :create, :new, :edit, :update, :destroy]
      resource.formats    = [:html]
      resource.denied.actions  = [:index, :show, :create, :new, :edit, :update, :destroy]
      resource.denied.flash = /You must be logged in to access this feature/i
      resource.denied.redirect = "login_path"
    end

  end       

  context "logged in as user" do

    setup do
      login_as :quentin
    end

    context "create a group" do
      setup do
        create_group_post(:name => "qgroup", :default_role => 'dude')
      end

      should_set_the_flash_to(/Group was successfully created/i)

      should "set the default role as a symbol" do
        @new_group = Group.find_by_url_key("qgroup")
        assert @new_group.default_role == :dude 
      end             
    end

    context "view user's groups" do
      setup do
        get :index, :user_id => @user.to_param
      end
      should_respond_with :success
      should_render_template :index
    end

  end


  protected
  def create_group_post(options = {})
    post :create, :group => { :name => 'new group', 
                              :description => 'this is a new group',
                              :default_role => 'member' }.merge(options)
    end

  end