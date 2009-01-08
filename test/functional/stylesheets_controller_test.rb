require File.dirname(__FILE__) + '/../test_helper'

class StylesheetsControllerTest < ActionController::TestCase

  def setup
    @controller = StylesheetsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  context 'get custom css' do
    setup do
      get :custom, { :format => 'css' }
    end
    should_respond_with :success
    should_render_template :custom
  end

end