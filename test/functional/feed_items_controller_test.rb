require File.dirname(__FILE__) + '/../test_helper'

class FeedItemsControllerTest < ActionController::TestCase

  context "not logged in" do

    context "DELETE to :destroy" do
      setup do
        @user = users(:quentin)
        @feed_item = feed_items(:one)
        delete :destroy, { :user_id => @user.to_param, :id => @feed_item.id }
      end

      should_redirect_to "login_path"
      should_set_the_flash_to(/You must be logged in to access this feature/i)
    end

  end

  context "logged in as feed item owner" do

    setup do 
      login_as :quentin
      @user = users(:quentin)
      @feed_item = feed_items(:one)
    end

    context "DELETE to :destroy html format" do

      setup do
        delete :destroy, { :user_id => @user.to_param, :id => @feed_item.id }
      end

      should_redirect_to "user_path(@user)"
      should_set_the_flash_to(/Item successfully removed from the recent activities list/i)

      should "delete feed item" do
        feed_item = @user.feeds.find(:first, :conditions => { :feed_item_id => @feed_item.id })
        assert feed_item.nil?
      end
    end

    context "DELETE to :destroy js format" do
      setup do
        delete :destroy, { :user_id => @user.to_param, :id => @feed_item.id, :format => 'js' }
      end

      should_respond_with :success

      should "delete feed item" do
        feed_item = @user.feeds.find(:first, :conditions => { :feed_item_id => @feed_item.id })
        assert feed_item.nil?
      end
    end
  end

end
