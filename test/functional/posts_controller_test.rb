require File.dirname(__FILE__) + '/../test_helper'

class PostsControllerTest < Test::Unit::TestCase
  
  def setup
    @controller = PostsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  # TODO get all the post tests working
  # should "create reply" do 
  #   counts = lambda { [Post.count, forums(:rails).posts_count, users(:aaron).posts_count, topics(:pdi).posts_count] }
  #   equal  = lambda { [forums(:rails).topics_count] }
  #   old_counts = counts.call
  #   old_equal  = equal.call
  # 
  #   login_as :aaron
  #   post :create, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :post => { :body => 'blah' }
  #   assert_redirected_to forum_topic_path(:forum_id => forums(:rails).id, :id => topics(:pdi).id, :anchor => assigns(:post).dom_id, :page => '1', :per_page => '1')
  #   assert_equal topics(:pdi), assigns(:topic)
  #   [forums(:rails), users(:aaron), topics(:pdi)].each &:reload
  # 
  #   assert_equal old_counts.collect { |n| n + 1}, counts.call
  #   assert_equal old_equal, equal.call
  # end
  # 
  # should "update topic replied at upon replying" do
  #    old=topics(:pdi).replied_at
  #    login_as :aaron
  #    post :create, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :post => { :body => 'blah' }
  #    assert_not_equal(old, topics(:pdi).reload.replied_at)
  #    assert old < topics(:pdi).reload.replied_at
  #  end
  #  
  # should "reply with no body" do
  #   assert_difference "Post.count", 0 do
  #     login_as :aaron
  #     post :create, :forum_id => forums(:rails).id, :topic_id => posts(:pdi).id, :post => {}
  #     assert_redirected_to forum_topic_path(:forum_id => forums(:rails).id, :id => posts(:pdi).id, :anchor => 'reply-form', :page => '1', :per_page => '1')
  #   end
  # end
  # 
  # should "delete reply" do
  #   counts = lambda { [Post.count, forums(:rails).posts_count, users(:sam).posts_count, topics(:pdi).posts_count] }
  #   equal  = lambda { [forums(:rails).topics_count] }
  #   old_counts = counts.call
  #   old_equal  = equal.call
  # 
  #   login_as :admin
  #   delete :destroy, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :id => posts(:pdi_reply).id
  #   assert_redirected_to forum_topic_path(:forum_id => forums(:rails).id, :id => topics(:pdi), :page => '1', :per_page => '1')
  #   [forums(:rails), users(:sam), topics(:pdi)].each &:reload
  # 
  #   assert_equal old_counts.collect { |n| n - 1}, counts.call
  #   assert_equal old_equal, equal.call
  # end
  # 
  # should "delete reply with xml" do
  #   content_type 'application/xml'
  #   authorize_as :admin
  #   delete :destroy, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :id => posts(:pdi_reply).id, :format => 'xml'
  #   assert_response :success
  # end
  # 
  # should "delete reply as moderator" do
  #   assert_difference "Post.count", -1 do
  #     login_as :sam
  #     delete :destroy, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :id => posts(:pdi_rebuttal).id
  #   end
  # end
  # 
  # should "delete topic if deleting the last reply" do
  #   assert_difference "Post.count", -1 do
  #     assert_difference "Topic.count", -1 do
  #       login_as :admin
  #       delete :destroy, :forum_id => forums(:rails).id, :topic_id => topics(:il8n).id, :id => posts(:il8n).id
  #       assert_redirected_to forum_path(forums(:rails).id)
  #       assert_raise(ActiveRecord::RecordNotFound) { topics(:il8n).reload }
  #     end
  #   end
  # end
  #  
  # should "be ablet to add new post" do
  #   login_as :sam
  #   get :new
  # end
  # should "be able to edit own post" do
  #   login_as :sam
  #   put :update, :forum_id => forums(:comics).id, :topic_id => topics(:galactus).id, :id => posts(:silver_surfer).id, :post => {}
  #   assert_redirected_to forum_topic_path(:forum_id => forums(:comics).id, :id => topics(:galactus), :anchor => posts(:silver_surfer).dom_id, :page => '1', :per_page => '1')
  # end
  # 
  # should "be able to edit own post with xml" do
  #   content_type 'application/xml'
  #   authorize_as :sam
  #   put :update, :forum_id => forums(:comics).id, :topic_id => topics(:galactus).id, :id => posts(:silver_surfer).id, :post => {}, :format => 'xml'
  #   assert_response :success
  # end
  #  
  # should "be able to edit other post as moderator" do
  #   login_as :sam
  #   put :update, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :id => posts(:pdi_rebuttal).id, :post => {}
  #   assert_redirected_to forum_topic_path(:forum_id => forums(:rails).id, :id => posts(:pdi), :anchor => posts(:pdi_rebuttal).dom_id, :page => '1', :per_page => '1')
  # end
  # 
  # should "not be able to edit other post" do
  #   login_as :sam
  #   put :update, :forum_id => forums(:comics).id, :topic_id => topics(:galactus).id, :id => posts(:galactus).id, :post => {}
  #   assert_redirected_to login_path
  # end
  # 
  # should "not be able to edit_other_post_with_xml" do
  #   content_type 'application/xml'
  #   authorize_as :sam
  #   put :update, :forum_id => forums(:comics).id, :topic_id => topics(:galactus).id, :id => posts(:galactus).id, :post => {}, :format => 'xml'
  #   assert_response 401
  # end
  # 
  # should "not be able to edit own post user id" do
  #   login_as :sam
  #   put :update, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :id => posts(:pdi_reply).id, :post => { :user_id => 32 }
  #   assert_redirected_to forum_topic_path(:forum_id => forums(:rails).id, :id => posts(:pdi), :anchor => posts(:pdi_reply).dom_id, :page => '1', :per_page => '1')
  #   assert_equal users(:sam).id, posts(:pdi_reply).reload.user_id
  # end
  # 
  # should "be able to edit other post as admin" do
  #   login_as :admin
  #   put :update, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :id => posts(:pdi_rebuttal).id, :post => {}
  #   assert_redirected_to forum_topic_path(:forum_id => forums(:rails).id, :id => posts(:pdi), :anchor => posts(:pdi_rebuttal).dom_id, :page => '1', :per_page => '1')
  # end
  # 
  # should "view post as xml" do
  #   get :show, :forum_id => forums(:rails).id, :topic_id => topics(:pdi).id, :id => posts(:pdi_rebuttal).id, :format => 'xml'
  #   assert_response :success
  #   assert_select 'post'
  # end
  # 
  # should "view recent posts" do
  #   get :index, :per_page => 20
  #   assert_response :success
  #   assert_models_equal [posts(:il8n), posts(:shield_reply), posts(:shield), posts(:silver_surfer), 
  #                       posts(:galactus), posts(:ponies), posts(:pdi_rebuttal), posts(:pdi_reply), posts(:pdi), posts(:sticky)], 
  #                       assigns(:posts)
  #   assert_select 'html>head'
  # end
  #   
  # should "view posts by forum" do
  #   get :index, :forum_id => forums(:comics).id, :per_page => 20
  #   assert_response :success
  #   assert_models_equal [posts(:shield_reply), posts(:shield), posts(:silver_surfer), posts(:galactus)], assigns(:posts)
  #   assert_select 'html>head'
  # end
  # 
  # should "view posts by user" do
  #   get :index, :user_id => users(:sam).id, :per_page => 20
  #   assert_response :success
  #   assert_models_equal [posts(:shield), posts(:silver_surfer), posts(:ponies), posts(:pdi_reply), posts(:sticky)], assigns(:posts)
  #   assert_select 'html>head'
  # end
  #   
  # should "view recent posts with xml" do
  #   content_type 'application/xml'
  #   get :index, :format => 'xml', :per_page => 20
  #   assert_response :success
  #   assert_models_equal [posts(:il8n), posts(:shield_reply), posts(:shield), posts(:silver_surfer), posts(:galactus), posts(:ponies), posts(:pdi_rebuttal), posts(:pdi_reply), posts(:pdi), posts(:sticky)], assigns(:posts)
  #   assert_select 'posts>post'
  # end
  # 
  # should "view posts by forum with xml" do
  #   content_type 'application/xml'
  #   get :index, :forum_id => forums(:comics).id, :format => 'xml', :per_page => 20
  #   assert_response :success
  #   assert_models_equal [posts(:shield_reply), posts(:shield), posts(:silver_surfer), posts(:galactus)], assigns(:posts)
  #   assert_select 'posts>post'
  # end
  # 
  # should "view posts by user with xml" do
  #   content_type 'application/xml'
  #   get :index, :user_id => users(:sam).id, :format => 'xml', :per_page => 20
  #   assert_response :success
  #   assert_models_equal [posts(:shield), posts(:silver_surfer), posts(:ponies), posts(:pdi_reply), posts(:sticky)], assigns(:posts)
  #   assert_select 'posts>post'
  # end
  # 
  # should "view monitored posts" do
  #   get :monitored, :user_id => users(:aaron).id
  #   assert_models_equal [posts(:pdi_reply)], assigns(:posts)
  # end
  # 
  # should "not view unmonitored posts" do
  #   get :monitored, :user_id => users(:sam).id
  #   assert_models_equal [], assigns(:posts)
  # end 
  # 
  # should "search recent posts" do
  #   get :search, :q => 'pdi', :per_page => 20
  #   assert_response :success
  #   assert_models_equal [posts(:pdi_rebuttal), posts(:pdi_reply), posts(:pdi)], assigns(:posts)
  # end
  # 
  # should "search posts by forum" do
  #   get :search, :forum_id => forums(:comics).id, :q => 'galactus', :per_page => 20
  #   assert_response :success
  #   assert_models_equal [posts(:silver_surfer), posts(:galactus)], assigns(:posts)
  # end
  # 
  # should "view recent posts as rss" do
  #   get :index, :format => 'rss', :per_page => 20
  #   assert_response :success
  #   assert_models_equal [posts(:il8n), posts(:shield_reply), posts(:shield), posts(:silver_surfer), posts(:galactus), posts(:ponies), posts(:pdi_rebuttal), posts(:pdi_reply), posts(:pdi), posts(:sticky)], assigns(:posts)
  # end
  # 
  # should "view posts by forum as rss" do
  #   get :index, :forum_id => forums(:comics).id, :format => 'rss', :per_page => 20
  #   assert_response :success
  #   assert_models_equal [posts(:shield_reply), posts(:shield), posts(:silver_surfer), posts(:galactus)], assigns(:posts)
  # end
  # 
  # should "view posts by user as rss" do
  #   get :index, :user_id => users(:sam).id, :format => 'rss', :per_page => 20
  #   assert_response :success
  #   assert_models_equal [posts(:shield), posts(:silver_surfer), posts(:ponies), posts(:pdi_reply), posts(:sticky)], assigns(:posts)
  # end
  
  should "disallow new post to locked topic" do
    galactus = topics(:galactus)
    galactus.locked = 1
    galactus.save
    login_as :aaron
    post :create, :forum_id => forums(:comics).id, :topic_id => topics(:galactus).id, :post => { :body => 'blah' }
    assert_redirected_to forum_topic_path(:forum_id => forums(:comics).id, :id => topics(:galactus))
    assert_equal 'This topic is locked.', flash[:notice]
  end
  
end
