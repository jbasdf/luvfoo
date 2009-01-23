require File.dirname(__FILE__) + '/../../test_helper'

class Groups::EventsControllerTest < ActionController::TestCase

  def setup
    @controller = Groups::EventsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @group = groups(:africa)
  end

  def self.should_allow_anyone

    context "GET index" do
      setup { get :index, :group_id => groups(:africa).to_param }
      should_respond_with :success 
      should_render_template :index
    end

    context "GET show" do
      setup { get :show, :group_id => groups(:africa).to_param, :id => events(:africa_news) }
      should_respond_with :success
      should_render_template :show  
    end

  end

  # make sure un-authorized can't get to resources
  def self.should_deny_unauthorized_users(group = :group, event = :event)

    context "deny unauthorized users" do

      setup do
        @group_to_test = self.instance_variable_get("@#{group.to_s}")
        @event_to_test = self.instance_variable_get("@#{event.to_s}")
      end

      should "not allow access to new" do
        get :new, :group_id => @group_to_test.to_param
        assert_redirected_to group_events_path(@group_to_test)
        ensure_flash(PERMISSION_DENIED_MSG)
      end

      should "not allow edit" do
        get :edit, :group_id => @group_to_test.to_param, :id => @event_to_test.to_param
        assert_redirected_to group_events_path(@group_to_test)
        ensure_flash(PERMISSION_DENIED_MSG)
      end

      should "not allow create" do
        post :create, :group_id => @group_to_test.to_param, :event => {:title => 'the title', :body => 'the body'}
        assert_redirected_to group_events_path(@group_to_test)
        ensure_flash(PERMISSION_DENIED_MSG)
      end

      should "not allow update" do
        post :update, :group_id => @group_to_test.to_param, :event_id => @event_to_test.to_param, :event => {:title => 'the title', :body => 'the body'}
        assert_redirected_to group_events_path(@group_to_test)
        ensure_flash(PERMISSION_DENIED_MSG)
      end

      should "not allow destroy" do
        delete :destroy, :group_id => @group_to_test.to_param, :event_id => @event_to_test.to_param
        assert_redirected_to group_events_path(@group_to_test)
        ensure_flash(PERMISSION_DENIED_MSG)
      end

    end

  end

  # only managers
  def self.should_allow_authorized_users

    context "allow authorized users" do

      setup do
        @group = groups(:africa)
        @event = Factory(:event)
      end

      context "GET new" do
        setup { get :new, :group_id => @group.to_param }
        should_respond_with :success  
        should_render_template :new
      end

      context "GET edit" do
        setup { get :edit, :group_id => @group.to_param, :id => @event }
        should_respond_with :success 
        should_render_template :edit
      end

      context "POST create" do
        setup do
          assert_difference "Event.count" do
            post :create, :group_id => @group.to_param, :event => {:title => 'the title', :body => 'the body'} 
          end
        end

        should_redirect_to "group_news_path(@group, @event)"
      end

      context "PUT update" do
        setup do
          assert_no_difference "Event.count" do
            post :update, :group_id => @group.to_param, :id => @event.to_param, :event => {:title => 'the title', :body => 'the body'} 
          end
        end
        should_redirect_to "group_news_path(@group, @event)"
      end

      context "DELETE " do
        setup do
          assert_difference "Event.count", -1 do
            delete :destroy, :group_id => @group.to_param, :id => @event.to_param
          end
        end
        should_redirect_to "group_events_path(@group)"
      end

    end

  end

  context "not logged in" do
    context "GET new" do
      setup { get :new, :group_id => groups(:africa).to_param }
      should_redirect_to "login_path" 
    end

    context "GET edit" do
      setup { get :edit, :group_id => groups(:africa).to_param, :id => events(:africa_news) }
      should_redirect_to "login_path" 
    end

    context "POST create" do
      setup { post :create, :group_id => groups(:africa).to_param, :event => {:title => 'the title', :body => 'the body'} }
      should_redirect_to "login_path"
    end

    context "PUT update" do
      setup { post :update, :group_id => groups(:africa).to_param, :event_id => events(:africa_news).to_param, :event => {:title => 'the title', :body => 'the body'} }
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