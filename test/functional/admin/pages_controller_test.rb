require File.dirname(__FILE__) + '/../../test_helper'

class Admin::PagesControllerTest < ActionController::TestCase

  def setup
    @controller =  Admin::PagesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  should_require_login :index, :show, :edit, :update, :destroy 

  context "logged in as admin" do
    setup do
      login_as :admin
    end

    context "GET index" do
      setup do
        get :index
      end
      should_respond_with :success
    end
    
    context "GET index - js" do
      setup do
        get :index, :format => 'js'
      end
      should_respond_with :success
    end
    
    context "GET new" do
      setup do
        get :new
      end
      should_respond_with :success
    end
    
    context "GET edit" do
      setup do
        get :edit, { :id => content_pages(:quentins_page).id }
      end
      should_respond_with :success
    end
    
    context "POST create" do
      setup do
        post :create, :content_page => {:title => 'title', :body_raw => 'raw body'}
      end
      should_redirect_to "admin_pages_path"
    end
    
    context "PUT update" do
      setup do
        put :update, :content_page => {:title => 'title', :body_raw => 'raw body'}
      end
      should_respond_with :success
    end
    
    context "PUT update only permalink" do
      setup do
        put :update, :id => content_pages(:quentins_page).id, :url_key => 'test', :only_permalink => true        	
      end
      should_respond_with :success
    end
    
    context "PUT update only parent" do
      setup do
        put :update, :id => content_pages(:quentins_sub_page).id, :parent_id => content_pages(:quentins_page).id, :only_parent => true        	
      end
      should_respond_with :success
      should 'contain parent_id' do
        assert @response.body.include?('parent_id')
      end
       
    end
    
  end

end
