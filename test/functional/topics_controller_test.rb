require File.dirname(__FILE__) + '/../test_helper'

class TopicsControllerTest < Test::Unit::TestCase
  
  def setup
    @controller = TopicsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # # page sure we have a special page link back to the last page
  # # of the forum we're currently viewing
  # should "have page link to forum" do
  #   @request.session[:forum_page]=Hash.new(1)
  #   @request.session[:forum_page][1]=911
  #   get :show, :forum_id => forums(:rails).to_param, :id => topics(:pdi).id
  #   assert_tag :tag => "a", :content => "page 911"
  # end

  context "main forum functionality" do
    
    should "get index" do
      get :index, :forum_id => forums(:rails).to_param
      assert_redirected_to forum_path(forums(:rails).to_param)
    end
   
    should "get index as xml" do
      content_type 'application/xml'
      get :index, :forum_id => forums(:rails).to_param, :format => 'xml'
      assert_response :success
      assert_select 'topics>topic'
    end
  
    should "show topic as rss" do
      get :show, :forum_id => forums(:rails).to_param, :id => topics(:pdi).id, :format => 'rss'
      assert_response :success
      assert_select 'channel'
    end
  
    should "show topic as xml" do
      content_type 'application/xml'
      get :show, :forum_id => forums(:rails).to_param, :id => topics(:pdi).id, :format => 'xml'
      assert_response :success
      assert_select 'topic'
    end
  
    should "get new" do
      login_as :aaron
      get :new, :forum_id => forums(:rails).to_param
      assert_response :success
    end
  
    should "protect sticky and locked from non admin" do
      login_as :joe
      assert ! users(:joe).admin?
      assert ! users(:joe).moderator_of?(:rails)
      post :create, :forum_id => forums(:rails).id, :topic => { :title => 'blah', :sticky => "1", :locked => "1", :body => 'foo' }
      assert assigns(:topic)
      assert ! assigns(:topic).sticky?
      assert ! assigns(:topic).locked?
    end
  
    should "allow sticky and locked to moderator" do
      login_as :sam
      assert ! users(:sam).admin?
      assert users(:sam).moderator_of?(forums(:rails))
      post :create, :forum_id => forums(:rails).id, :topic => { :title => 'blah', :sticky => "1", :locked => "1", :body => 'foo' }
      assert assigns(:topic)
      assert assigns(:topic).sticky?
      assert assigns(:topic).locked?
    end
    
    should "allow admin to sticky and lock" do
      login_as :admin
      post :create, :forum_id => forums(:rails).id, :topic => { :title => 'blah2', :sticky => "1", :locked => "1", :body => 'foo' }
      assert assigns(:topic).sticky?
      assert assigns(:topic).locked?
    end
  
    uses_transaction :test_should_not_create_topic_without_body
  
    should "not create topic without body" do
      counts = lambda { [Topic.count, Post.count] }
      old = counts.call    
      login_as :admin    
      post :create, :forum_id => forums(:rails).id, :topic => { :title => 'blah' }
      assert assigns(:topic)
      assert assigns(:post)
      # both of these should be new records if the save fails so that the view can
      # render accordingly
      assert assigns(:topic).new_record?
      assert assigns(:post).new_record?    
      assert_equal old, counts.call
    end
  
    should "not create topic without title" do
      counts = lambda { [Topic.count, Post.count] }
      old = counts.call    
      login_as :admin    
      post :create, :forum_id => forums(:rails).id, :topic => { :body => 'blah' }
      assert_equal "blah", assigns(:topic).body
      assert assigns(:post)
      # both of these should be new records if the save fails so that the view can
      # render accordingly
      assert assigns(:topic).new_record?
      assert assigns(:post).new_record?    
      assert_equal old, counts.call
    end
  
    should "create topic" do
      counts = lambda { [Topic.count, Post.count, forums(:rails).topics_count, forums(:rails).posts_count,  users(:admin).posts_count] }
      old = counts.call    
      login_as :admin
      post :create, :forum_id => forums(:rails).to_param, :topic => { :title => 'blah', :body => 'foo' }
      assert assigns(:topic)
      assert assigns(:post)
      assert_redirected_to forum_topic_path(forums(:rails), assigns(:topic))
      [forums(:rails), users(:admin)].each &:reload  
      assert_equal old.collect { |n| n + 1}, counts.call
    end
  
    should "create topic with xml" do
      content_type 'application/xml'
      authorize_as :admin
      post :create, :forum_id => forums(:rails).id, :topic => { :title => 'blah', :body => 'foo' }, :format => 'xml'
      assert_response :created
      assert_equal formatted_forum_topic_url(:forum_id => forums(:rails), :id => assigns(:topic), :format => :xml), @response.headers["Location"]
    end
  
    should "delete topic" do
      counts = lambda { [Post.count, forums(:rails).topics_count, forums(:rails).posts_count] }
      old = counts.call    
      login_as :admin
      delete :destroy, :forum_id => forums(:rails).to_param, :id => topics(:ponies).id
      assert_redirected_to forum_path(forums(:rails))
      [forums(:rails), users(:aaron)].each &:reload  
      assert_equal old.collect { |n| n - 1}, counts.call
    end
  
    should "delete topic with xml" do
      content_type 'application/xml'
      authorize_as :admin
      delete :destroy, :forum_id => forums(:rails).to_param, :id => topics(:ponies).id, :format => 'xml'
      assert_response :success
    end
  
    should "allow moderator to delete topic" do
      assert_difference "Topic.count", -1 do
        login_as :sam
        delete :destroy, :forum_id => forums(:rails).to_param, :id => topics(:pdi).id
      end
    end
  
    should "update views for show" do
      assert_difference "topics(:pdi).views" do
        get :show, :forum_id => forums(:rails).to_param, :id => topics(:pdi).id
        assert_response :success
        topics(:pdi).reload
      end
    end
  
    should "not update views for show via rss" do
      assert_difference "topics(:pdi).views", 0 do
        get :show, :forum_id => forums(:rails).to_param, :id => topics(:pdi).id, :format => 'rss'
        assert_response :success
        topics(:pdi).reload
      end
    end
  
    should "not add viewed topic to session on show rss" do
      login_as :aaron
      get :show, :forum_id => forums(:rails).id, :id => topics(:pdi).id, :format => 'rss'
      assert_response :success
      assert session[:topics].blank?
    end
  
    should "update views for show except topic author" do
      login_as :aaron
      views=topics(:pdi).views
      get :show, :forum_id => forums(:rails).id, :id => topics(:pdi).id
      assert_response :success
      assert_equal views, topics(:pdi).reload.views
    end
  
    should "show topic" do
      get :show, :forum_id => forums(:rails).id, :id => topics(:pdi).id, :per_page => 20
      assert_response :success
      assert_equal topics(:pdi), assigns(:topic)
      assert_models_equal [posts(:pdi), posts(:pdi_reply), posts(:pdi_rebuttal)], assigns(:posts)
    end
  
    should "show other post" do
      get :show, :forum_id => forums(:rails).id, :id => topics(:ponies).id
      assert_response :success
      assert_equal topics(:ponies), assigns(:topic)
      assert_models_equal [posts(:ponies)], assigns(:posts)
    end
   
    should "get edit" do
      login_as :admin
      get :edit, :forum_id => forums(:rails).id, :id => topics(:ponies).id
      assert_response :success
    end
  
    should "update own post" do
      login_as :sam
      put :update, :forum_id => forums(:rails).id, :id => topics(:ponies).id, :topic => { }
      assert_redirected_to forum_topic_path(forums(:rails), assigns(:topic))
    end
  
    should "update with xml" do
      content_type 'application/xml'
      authorize_as :sam
      put :update, :forum_id => forums(:rails).id, :id => topics(:ponies).id, :topic => { }, :format => 'xml'
      assert_response :success
    end
  
    should "not update user id of own post" do
      login_as :sam
      put :update, :forum_id => forums(:rails).id, :id => topics(:ponies).id, :topic => { :user_id => 32 }
      assert_redirected_to forum_topic_path(forums(:rails), assigns(:topic))
      assert_equal users(:sam).id, posts(:ponies).reload.user_id
    end
  
    should "not update other post" do
      login_as :sam
      put :update, :forum_id => forums(:comics).id, :id => topics(:galactus).id, :topic => { }
      assert_redirected_to login_path
    end
  
    should "not update other post with xml" do
      content_type 'application/xml'
      authorize_as :sam
      put :update, :forum_id => forums(:comics).id, :id => topics(:galactus).id, :topic => { }, :format => 'xml'
      assert_response :unauthorized
    end
   
    should "update other post as moderator" do
      login_as :sam
      put :update, :forum_id => forums(:rails).id, :id => topics(:pdi).id, :topic => { }
      assert_redirected_to forum_topic_path(forums(:rails), assigns(:topic))
    end
  
    should "update other post as admin" do
      login_as :admin
      put :update, :forum_id => forums(:rails).id, :id => topics(:ponies), :topic => { }
      assert_redirected_to forum_topic_path(forums(:rails), assigns(:topic))
    end
  end
  
  context "forums inside a group" do
    context 'show topic' do
      setup do
        get :show, :forum_id => forums(:africa).id, :id => topics(:nigeria).id, :per_page => 20
      end

      should_respond_with :success
      should_render_template "groups/topics/show"
      should_assign_to :topic
    
      should "assign topic" do
        assert_equal topics(:nigeria), assigns(:topic)
      end
    end
  end
  
end
