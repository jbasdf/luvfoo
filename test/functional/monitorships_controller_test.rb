require File.dirname(__FILE__) + '/../test_helper'

class MonitorshipsControllerTest < Test::Unit::TestCase
  
  def setup
    @controller = MonitorshipsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  should "require login" do
    login_as :admin
    xhr :post, :create, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :id => users(:admin).id
    assert_response :success
  end
  
  should "add monitorship" do
    login_as :joe
    assert_difference "Monitorship.count" do 
      xhr :post, :create, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :id => users(:joe).id
      assert_response :success
    end    
    assert topics(:pdi).monitors(true).include?(users(:joe))
  end
  
  should "activate monitorship" do
    login_as :sam
    assert_difference "Monitorship.count", 0 do
      xhr :post, :create, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :id => users(:sam).id
      assert_response :success
    end
  end
    
  should "not duplicate monitorship" do
    login_as :aaron
    assert_difference "Monitorship.count", 0 do
      xhr :post, :create, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :id => users(:aaron).id
      assert_response :success
    end
  end
  
  should "deactivate monitorship" do
    login_as :aaron
    assert_difference "Monitorship.count", 0 do
      xhr :delete, :destroy, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :id => users(:aaron).id
      assert_response :success
    end  
    assert !topics(:pdi).monitors(true).include?(users(:aaron))
  end
  
  should "require login with html" do
    post :create, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :id => users(:aaron).id
    assert_redirected_to login_path
  end
  
  should "add monitorship with html" do
    login_as :joe
    assert_difference "Monitorship.count" do 
      post :create, :forum_id => forums(:rails).to_param, :topic_id => topics(:pdi).id, :id => users(:joe).id
      assert_redirected_to forum_topic_path(forums(:rails), topics(:pdi))
    end    
    assert topics(:pdi).monitors(true).include?(users(:joe))
  end
  
  should "deactivate monitorship with html" do
    login_as :admin
    assert_difference "Monitorship.count", 0 do
      delete :destroy, :forum_id => forums(:rails).to_param, :topic_id => topics(:pdi).id, :id => users(:admin).id
      assert_redirected_to forum_topic_path(forums(:rails), topics(:pdi))
    end  
    assert !topics(:pdi).monitors(true).include?(users(:admin))
  end
  
end
