require File.dirname(__FILE__) + '/../../test_helper'

class Users::StatusUpdatesControllerTest < Test::Unit::TestCase

  def setup
    @controller = Users::StatusUpdatesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  should_require_login :create, :destroy
 

  context "logged in" do
    
    setup do
      @user = Factory(:user)
      @user2 = Factory(:user)
      login_as @user
    end

    context "POST create" do
      
      context "html format" do
        setup do
          post :create, :status_update => {:text => 'a new status update'}
        end
        should_redirect_to "user_path(@user)"
      end

      should "be able to update status that includes user's name" do
        assert_difference "StatusUpdate.count", 1 do
           post :create, :status_update => {:text => @user.short_name + ' is updating his status'}
        end
      end
            
      should "be able to update status" do
        assert_difference "StatusUpdate.count", 1 do
           post :create, :status_update => {:text => 'a new status update'}
        end
      end

      should "be able to update status (js)" do
        assert_difference "StatusUpdate.count", 1 do
           post :create, :status_update => {:text => 'a new status update'}, :format => 'js'
        end
      end

      should "not be ablet o update someone elses status" do
        assert_no_difference "@user2.status_updates.count" do
           post :create, :status_update => {:text => 'a new status update'}, :user_id => @user2.id
        end
      end
      
    end
    
    context "DELETE destroy" do
      
      should "be able to delete status (js)" do
        @status_update = @user.status_updates.create(:text => 'test')
        assert_difference "StatusUpdate.count", -1 do
          delete :destroy, { :id => @status_update.id, :format => 'js' }
        end
      end
      
      should "be able to delete status" do
        @status_update = @user.status_updates.create(:text => 'test')
        assert_difference "StatusUpdate.count", -1 do
          delete :destroy, { :id => @status_update.id }
          ensure_flash(/Status update successfully removed/i)
        end
      end
            
    end
    
  end

end