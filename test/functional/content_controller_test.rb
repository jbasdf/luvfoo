require File.dirname(__FILE__) + '/../test_helper'

class ContentControllerTest < ActionController::TestCase

  def setup
    @controller = ContentController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  context 'anonymous' do
    
    context 'request page' do
      setup do
        get :show_page, :content_page => ['default']
      end
      should_respond_with :success
    end
  
    context 'request non-existant page' do
      setup do
        get :show_page, :content_page => 'test'
      end
      should_respond_with 404
    end

    context 'request protected page' do
      setup do
        get :show_protected_page, :content_page => 'test'
      end
      should_redirect_to 'login_path'
    end

  end

  context 'logged in' do
    
    setup do
      login_as :quentin
    end
    
    context 'request protected page' do
      setup do
        get :show_protected_page, :content_page => ['default']
      end
      should_respond_with :success
    end

  end
  
end
