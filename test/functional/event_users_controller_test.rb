require File.dirname(__FILE__) + '/../test_helper'

class EventUsersControllerTest < Test::Unit::TestCase

  should_require_login :create, :destroy
  
  
end