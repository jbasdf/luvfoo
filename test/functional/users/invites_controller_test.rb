require File.dirname(__FILE__) + '/../../test_helper'

class Users::InvitesControllerTest < Test::Unit::TestCase

  def setup
    @controller = Users::InvitesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @user = users(:quentin)
  end

  def self.should_deny_unauthorized_users
    context "GET new" do
      setup { get :new }
      should_redirect_to "login_path" 
    end

    context "POST create" do
      setup do
        post :create
      end
      should_redirect_to "login_path"
    end
  end

  context "not logged in" do
    should_deny_unauthorized_users
  end

  context "logged in" do
    setup do
      login_as @user
    end

    context "GET new" do
      setup { get :new }
      should_respond_with :success  
      should_render_template :new
    end

    context "POST create" do
      setup do
        post :create, :subject => 'the subject', 
        :message => 'the message',
        :name => ['test guy'],
        :email => ['testguy@example.com']
      end
      should_redirect_to "user_path(@user)"
    end
  end

end