require File.dirname(__FILE__) + '/../test_helper'

class ForumsControllerTest < Test::Unit::TestCase
  
  def setup
    @controller = ForumsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # test remembering pages
  
  should "index resets page variable" do
    @request.session[:forum_page]=Hash.new(1)
    get :index, :id => forums(:rails).to_param
    assert_equal nil, session[:forum_page]
  end
  
  should "set page variable when viewing a forum" do
    get :show, :id => forums(:rails).to_param, :page => 3
    assert_equal 3, session[:forum_page][forums(:rails).id]
  end
  
  # should "log into home if remember token is set" do
  #   @request.cookies['auth_token'] = CGI::Cookie.new('auth_token', users(:sam).remember_token)
  #   get :index
  #   assert_equal users(:sam).id, session[:user_id]
  # end
  
  # should "log in with remember token when login required" do
  #   users(:aaron).remember_token = "8305f94ab2b92f99137abbc235ee28e5"
  #   users(:aaron).remember_token_expires_at = Time.now.utc+1.week
  #   users(:aaron).save!
  #   @request.cookies['auth_token'] = CGI::Cookie.new('auth_token', users(:sam).remember_token)
  #   get :edit, :id => users(:aaron).id
  #   assert_equal users(:aaron).id, session[:user_id]
  # end

  should "get index" do
    get :index
    assert_response :success
    assert assigns(:forums)
    assert_select 'html>head'
  end
  
  should "get index as xml" do
    content_type 'application/xml'
    get :index, :format => 'xml'
    assert_response :success
    assert_select 'forums>forum'
  end
  
  should "get new" do
    login_as :admin
    get :new
    assert_response :success
  end
  
  should "require admin" do
    login_as :sam
    get :new
    assert_redirected_to login_path
  end
  
  should "create forum" do
    login_as :admin
    assert_difference "Forum.count", 1 do
      post :create, :forum => { :name => 'yeah' }
    end    
    assert_redirected_to forum_path(assigns(:forum))
  end
  
  should "create forum with xml" do
    content_type 'application/xml'
    authorize_as :admin  
    assert_difference "Forum.count", 1 do
      post :create, :forum => { :name => 'yeah' }, :format => 'xml'
    end    
    assert_response :created
    assert_equal formatted_forum_url(:id => assigns(:forum), :format => :xml), @response.headers["Location"]
  end
  
  should "show forum" do
    get :show, :id => forums(:rails).to_param
    assert_response :success
    assert assigns(:topics)
    # sticky should be first
    assert_equal(topics(:sticky), assigns(:topics).first)
    assert_select 'html>head'
  end
  
  should "show forum with xml" do
    content_type 'application/xml'
    get :show, :id => forums(:rails).to_param, :format => 'xml'
    assert_response :success
    assert_select 'forum'
  end
  
  should "get edit" do
    login_as :admin
    get :edit, :id => forums(:rails).to_param
    assert_response :success
  end
  
  should "update forum" do
    login_as :admin
    put :update, :id => forums(:rails).to_param, :forum => { }
    assert_redirected_to forum_path(forums(:rails))
  end
  
  should "update forum with xml" do
    authorize_as :admin
    content_type 'application/xml'
    put :update, :id => forums(:rails).to_param, :forum => { }, :format => 'xml'
    assert_response :success
  end
  
  should "destroy forum" do
    login_as :admin
    old_count = Forum.count
    delete :destroy, :id => forums(:rails).to_param
    assert_equal old_count-1, Forum.count  
    assert_redirected_to forums_path
  end
  
  should "destroy forum with xml" do
    authorize_as :admin
    content_type 'application/xml'
    old_count = Forum.count
    delete :destroy, :id => forums(:rails).to_param, :format => 'xml'
    assert_equal old_count-1, Forum.count
    assert_response :success
  end
  
end
