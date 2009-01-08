require File.dirname(__FILE__) + '/../../test_helper'

class Groups::InvitesControllerTest < Test::Unit::TestCase

  def setup
    @controller = Groups::InvitesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @group = groups(:africa)
  end

  def self.should_deny_unauthorized_users
    context "GET new" do
      setup { get :new, :group_id => groups(:africa).to_param }
      should_redirect_to "group_path(@group)" 
    end

    context "POST create" do
      setup do
        post :create, :group_id => groups(:africa).to_param
      end
      should_redirect_to "group_path(@group)"
    end
  end

  context "not logged in" do
    should_deny_unauthorized_users
  end

  context "logged in not a member" do
    setup do
      login_as users(:aaron).login        
    end
    should_deny_unauthorized_users
  end

  context "logged in member" do
    setup do
      login_as users(:africa_member).login
    end

    context "GET new" do
      setup { get :new, :group_id => groups(:africa).to_param }
      should_respond_with :success  
      should_render_template :new
    end

    context "POST create" do
      setup do
        post :create, :group_id => groups(:africa).to_param, 
        :subject => 'the subject', 
        :message => 'the message',
        :name => ['test guy'],
        :email => ['testguy@example.com']

      end
      should_redirect_to "group_path(@group)"
    end
  end

end