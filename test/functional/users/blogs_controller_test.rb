require File.dirname(__FILE__) + '/../../test_helper'

class Users::BlogsControllerTest < Test::Unit::TestCase

  def setup
    @controller = Users::BlogsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @user       = users(:quentin)
    @news_item  = news_items(:blog_post)
  end

  should_require_login :index, :show, :new, :create, :edit, :update, :destroy

  context "logged in as different user" do
    setup do
      login_as users(:aaron).login
    end

    context "GET index" do
      setup do
        get :index, :user_id => @user.to_param
      end
      should_respond_with :success
      should_render_template :index

      should "render aaron's blog posts" do
        assert session[:user_id] == users(:aaron).id
      end

    end

    context "GET index js" do
      setup { get :index, :user_id => @user.to_param, :format => 'js' }
      should_respond_with :success
    end
    
    context 'on POST to :create' do
      setup do
        @quentin_post_count = @user.blogs.count
        @aaron_post_count = users(:aaron).blogs.count
        post :create, :user_id => @user.to_param, :news_item => {:title => 'new blog post', :body => 'body of the post'}
      end
      should_redirect_to "user_blogs_path(@user)"
      should_set_the_flash_to(/created/i)

      should "render create a blog post for aaron not quentin" do
        assert session[:user_id] == users(:aaron).id
        assert @quentin_post_count == @user.blogs.count
        assert (@aaron_post_count + 1) == users(:aaron).blogs.count
      end
    end

  end

  context "logged in as owner" do
    setup do
      login_as users(:quentin).login
    end

    context "GET index" do
      setup do
        get :index, :user_id => @user.to_param
      end
      should_respond_with :success
      should_render_template :index
    end

    context "GET new" do
      setup do
        get :new, :user_id => @user.to_param
      end
      should_respond_with :success
      should_render_template :new
    end

    context "GET edit" do
      setup do
        get :edit, :user_id => @user.to_param, :id => @news_item.to_param
      end
      should_respond_with :success
      should_render_template :edit
    end

    context 'on POST to :create' do
      setup do
        post :create, :user_id => @user.to_param, :news_item => {:title => 'new blog post', :body => 'body of the post'}
      end
      should_redirect_to "user_blogs_path(@user)"
      should_set_the_flash_to(/created/i)
    end

    context 'on PUT to :update' do
      setup do
        put :update, :user_id => @user.to_param, :id => @news_item.to_param, :news_item => {:title => 'new blog post', :body => 'body of the post'}
      end
      should_redirect_to "user_blogs_path(@user)"
      should_set_the_flash_to(/updated/i)
    end

    context 'on DELETE to :destroy' do
      setup do
        delete :destroy, {:user_id => @user.to_param, :id => @news_item.to_param}
      end
      should_redirect_to "user_blogs_path(@user)"
      should_set_the_flash_to(/delete/i)
    end

    context 'user with friends' do
      setup do
        @feed_item_before_count = FeedItem.count
        @feed_before_count = Feed.count
        post :create, :user_id => @user.to_param, :news_item => {:title => 'new blog post', :body => 'body of the post'}
      end

      should 'create new feed_item and feeds after creating a blog post' do
        assert FeedItem.count > @feed_item_before_count
        assert Feed.count > @feed_before_count
      end
    end

    # should_be_restful do |resource|
    #             resource.parent     = @user
    #             resource.klass      = NewsItem
    #             resource.object     = :news_item
    #             resource.formats    = [:html]
    #             resource.actions  = [:index, :new, :create, :edit, :update, :destroy]
    #             resource.update.redirect  = "user_blogs_path(@user)"
    #             resource.create.redirect  = "user_blogs_path(@user)" 
    #             resource.destroy.redirect = "user_blogs_path(@user)"
    #             resource.create.flash  = /created/i
    #             resource.update.flash  = /updated/i
    #             resource.destroy.flash = /deleted/i
    #             resource.create.params = { :title => "new blog title", :body => "this is the body" }
    #             resource.update.params = { :title => "edit blog title" }
    #         end
  end

  context 'POST to create - should create a feed item and feed for a new user' do
    setup do
      @user = Factory(:user)
      login_as @user
      @feed_item_before_count = FeedItem.count
      @feed_before_count = Feed.count
      post :create, :user_id => @user.to_param, :news_item => {:title => 'new blog post', :body => 'body of the post'}
    end

    should 'create new feed_item and feeds after creating a blog post' do
      assert FeedItem.count > @feed_item_before_count
      assert Feed.count > @feed_before_count
    end

  end

end