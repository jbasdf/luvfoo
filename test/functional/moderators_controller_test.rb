require File.dirname(__FILE__) + '/../test_helper'

class ModeratorsControllerTest < Test::Unit::TestCase
  
  def setup
    @controller = ModeratorsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  should "delete moderatorship" do
    assert users(:sam).moderator_of?(forums(:rails))
    login_as :admin
    assert_difference "Moderatorship.count", -1 do
      delete :destroy, :user_id => users(:sam).id, :id => moderatorships(:sam_rails).id
    end
    assert_redirected_to user_path(users(:sam).id)
    assert !users(:sam).moderator_of?(forums(:rails))
  end

  should "only allow admins to delete moderatorships" do
    login_as :sam
    assert_difference "Moderatorship.count", 0 do
      delete :destroy, :user_id => users(:sam).id, :id => moderatorships(:sam_rails).id
    end
    assert_redirected_to login_path
  end
  
end
