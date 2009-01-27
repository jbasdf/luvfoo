require File.dirname(__FILE__) + '/../../test_helper'

class Groups::NewsControllerTest < ActionController::TestCase

  def setup
    @controller = Groups::NewsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @group = groups(:africa)
    @news_item = news_items(:africa_news)
  end

  def self.should_allow_anyone

    context "GET index" do
      setup { get :index, :group_id => groups(:africa).to_param }
      should_respond_with :success 
      should_render_template :index
    end

    context "GET index js" do
      setup { get :index, :group_id => groups(:africa).to_param, :format => 'js' }
      should_respond_with :success
    end
        
    context "GET show" do
      setup { get :show, :group_id => groups(:africa).to_param, :id => news_items(:africa_news) }
      should_respond_with :success
      should_render_template :show  
    end

  end

  # make sure un-authorized can't get to resources
  def self.should_deny_unauthorized_users(group = :group, news_item = :news_item)

    context "deny unauthorized users" do

      setup do
        @group_to_test = self.instance_variable_get("@#{group.to_s}")
        @news_item_to_test = self.instance_variable_get("@#{news_item.to_s}")
      end

      should "not allow access to new" do
        get :new, :group_id => @group_to_test.to_param
        assert_redirected_to group_news_index_path(@group_to_test)
        ensure_flash(PERMISSION_DENIED_MSG)
      end

      should "not allow edit" do
        get :edit, :group_id => @group_to_test.to_param, :id => @news_item_to_test.to_param
        assert_redirected_to group_news_index_path(@group_to_test)
        ensure_flash(PERMISSION_DENIED_MSG)
      end

      should "not allow create" do
        post :create, :group_id => @group_to_test.to_param, :news_item => {:title => 'the title', :body => 'the body'}
        assert_redirected_to group_news_index_path(@group_to_test)
        ensure_flash(PERMISSION_DENIED_MSG)
      end

      should "not allow update" do
        post :update, :group_id => @group_to_test.to_param, :news_item_id => @news_item_to_test.to_param, :news_item => {:title => 'the title', :body => 'the body'}
        assert_redirected_to group_news_index_path(@group_to_test)
        ensure_flash(PERMISSION_DENIED_MSG)
      end

      should "not allow destroy" do
        delete :destroy, :group_id => @group_to_test.to_param, :news_item_id => @news_item_to_test.to_param
        assert_redirected_to group_news_index_path(@group_to_test)
        ensure_flash(PERMISSION_DENIED_MSG)
      end

    end

  end

  # only managers
  def self.should_allow_authorized_users

    context "allow authorized users" do

      setup do
        @group = groups(:africa)
        @news_item = news_items(:africa_news)
      end

      context "GET new" do
        setup { get :new, :group_id => @group.to_param }
        should_respond_with :success  
        should_render_template :new
      end

      context "GET edit" do
        setup { get :edit, :group_id => @group.to_param, :id => @news_item }
        should_respond_with :success 
        should_render_template :edit
      end

      context "POST create" do
        setup do
          assert_difference "NewsItem.count" do
            post :create, :group_id => @group.to_param, :news_item => {:title => 'the title', :body => 'the body'} 
          end
        end

        should_redirect_to "group_news_path(@group, @news_item)"
      end

      context "PUT update" do
        setup do
          assert_no_difference "NewsItem.count" do
            post :update, :group_id => @group.to_param, :id => @news_item.to_param, :news_item => {:title => 'the title', :body => 'the body'} 
          end
        end
        should_redirect_to "group_news_path(@group, @news_item)"
      end

      context "DELETE " do
        setup do
          assert_difference "NewsItem.count", -1 do
            delete :destroy, :group_id => @group.to_param, :id => @news_item.to_param
          end
        end
        should_redirect_to "group_news_index_path(@group)"
      end

    end

  end

  context "not logged in" do
    context "GET new" do
      setup { get :new, :group_id => groups(:africa).to_param }
      should_redirect_to "login_path" 
    end

    context "GET edit" do
      setup { get :edit, :group_id => groups(:africa).to_param, :id => news_items(:africa_news) }
      should_redirect_to "login_path" 
    end

    context "POST create" do
      setup { post :create, :group_id => groups(:africa).to_param, :news_item => {:title => 'the title', :body => 'the body'} }
      should_redirect_to "login_path"
    end

    context "PUT update" do
      setup { post :update, :group_id => groups(:africa).to_param, :news_item_id => news_items(:africa_news).to_param, :news_item => {:title => 'the title', :body => 'the body'} }
      should_redirect_to "login_path"
    end
  end

  context "logged in not a member" do
    setup do
      login_as users(:aaron).login        
    end
    should_allow_anyone
    should_deny_unauthorized_users
  end

  context "logged in member" do
    setup do
      login_as users(:africa_member).login
    end
    should_allow_anyone
    should_deny_unauthorized_users
  end

  context "logged in manager" do
    setup do
      login_as users(:africa_manager).login
    end
    should_allow_anyone
    should_allow_authorized_users
  end

  context "logged in group creator" do
    setup do
      login_as users(:quentin).login
    end
    should_allow_anyone
    should_allow_authorized_users
  end

  context "logged in admin" do
    setup do
      login_as users(:admin).login
    end
    should_allow_anyone
    should_allow_authorized_users
  end

end