require File.dirname(__FILE__) + '/../test_helper'

class MessagesControllerTest < ActionController::TestCase

  def setup
    @controller = MessagesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @message    = messages(:user_to_user2)
  end

  context 'logged in as user' do
    setup do
      login_as :quentin
    end

    context "GET index" do
      setup do
        get :index
      end
      should_respond_with :success
      should_render_template :index
    end

    context "GET show" do
      setup do
        get :show, :id => messages(:user_to_user2).id
      end
      should_respond_with :success
      should_render_template :show
    end

    context "get sent messages" do
      setup do
        get :sent
      end
      should_respond_with :success
      should_render_template :sent

    end

    context "create a new message" do
      setup do
        assert_difference "Message.count" do
          post :create, :message => {:subject => 'test', :body => 'message', :receiver_id => users(:quentin).id}
        end
      end
      should_respond_with :success
    end

    context "not create a new message (missing data)" do
      setup do
        assert_no_difference "Message.count" do
          post :create, :message => {:subject => '', :body => '', :receiver_id => users(:quentin).id}
        end
      end
    end

  end

  context 'logged in as admin' do
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

  context 'not logged in' do

    should_be_restful do |resource|
      resource.actions    = [:index, :show, :new, :create]
      resource.formats    = [:html]
      resource.denied.actions  = [:index, :show, :new, :create, :edit, :update, :destroy]
      resource.denied.flash = /You must be logged in to access this feature/i
    end

    context "GET index" do
      setup do
        get :index
      end
      should_redirect_to 'login_path'
    end

    context "get sent messages" do
      setup do
        get :sent
      end
      should_redirect_to 'login_path'            
    end

    context "POST to create" do
      setup do
        assert_no_difference "Message.count" do
          post :create, :message => {:subject => 'test', :body => 'message', :receiver_id => users(:quentin).id}
        end
      end
      should_redirect_to 'login_path' 
    end

  end

  context "logged in as can't message" do
    setup do
      login_as :cant_message
      assert_no_difference "Message.count" do
        post :create, :message => {:subject => 'test', :body => 'message', :receiver_id => users(:quentin).id}
      end
    end
    should_respond_with :success
    should "contain 'can't send message'" do
      assert_match "Sorry, you can't send messages", @response.body
    end
  end

end