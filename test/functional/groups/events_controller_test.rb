require File.dirname(__FILE__) + '/../../test_helper'

class Groups::EventsControllerTest < ActionController::TestCase

  should_require_login :new, :edit, :create, :update, :delete
  
  def setup
    @group = groups(:africa)
  end

  def self.should_allow_anyone

    context "GET index" do
      setup { get :index, :group_id => groups(:africa).to_param }
      should_respond_with :success 
      should_render_template :index
    end
    
    context "GET index (ics)" do
      setup { get :index, :group_id => groups(:africa).to_param, :format => 'ics' }
      should_respond_with :success 
    end
    
    context "GET show" do
      setup do
        @event = Factory(:event)
        get :show, :group_id => groups(:africa).to_param, :id => @event.to_param
      end 
      
      should_respond_with :success
      should_render_template :show  
    end

  end

  # make sure un-authorized can't get to resources
  def self.should_deny_unauthorized_users(group = :group, event = :event)

    context "deny unauthorized users" do

      setup do
        @group_to_test = self.instance_variable_get("@#{group.to_s}")
        @event_to_test = Factory(:event)
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
        post :create, :group_id => @group_to_test.to_param, :event => {:title => 'the title'}
        assert_redirected_to group_events_path(@group_to_test)
        ensure_flash(PERMISSION_DENIED_MSG)
      end

      should "not allow update" do
        post :update, :group_id => @group_to_test.to_param, :event_id => @event_to_test.to_param, :event => {:title => 'the title'}
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
            post :create, :group_id => @group.to_param, :event => {:title => 'the title', :summary => 'summary',
                                                                   :location => 'Seattle', :description => 'described',
                                                                   :start_at => DateTime.now + 2.days,
                                                                   :end_at => DateTime.now + 3.days } 
          end
        end

        should_redirect_to "group_events_path(@group)"
      end

      context "PUT update" do
        setup do
          assert_no_difference "Event.count" do
            post :update, :group_id => @group.to_param, :id => @event.to_param, :event => {:title => 'the title', :summary => 'summary',
                                                                                           :location => 'Seattle', :description => 'described',
                                                                                           :start_at => DateTime.now + 2.days,
                                                                                           :end_at => DateTime.now + 3.days} 
          end
        end
        should_redirect_to "group_events_path(@group)"
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