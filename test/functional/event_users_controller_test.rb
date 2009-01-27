require File.dirname(__FILE__) + '/../test_helper'

class EventUsersControllerTest < Test::Unit::TestCase
  
  def setup
    @controller = EventUsersController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  should_require_login :create, :destroy
    
end