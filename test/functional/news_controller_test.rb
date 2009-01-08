require File.dirname(__FILE__) + '/../test_helper'

class NewsControllerTest < ActionController::TestCase

  def setup
    @controller =  NewsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  should 'render main news page' do
    assert_nothing_raised do
      get :index
      assert_response :success
      assert_template 'index'
    end
  end

end
