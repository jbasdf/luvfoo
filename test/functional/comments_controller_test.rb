require File.dirname(__FILE__) + '/../test_helper'

class CommentsControllerTest < ActionController::TestCase

  def setup
    @controller = CommentsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  def self.should_be_able_to_delete_comments

    should "be able to delete comment on own blog" do
      assert_difference "Comment.count", -1 do
        delete :destroy, { :id => comments(:quentins_comment).id }
        ensure_flash(/comment successfully removed/i)
      end
    end

    should "be able to delete comment on own blog (js)" do
      assert_difference "Comment.count", -1 do
        delete :destroy, { :id => comments(:quentins_comment).id, :format => 'js' }
      end
    end

    should "be able to delete comment on group he created" do
      assert_difference "Comment.count", -1 do
        delete :destroy, { :id => comments(:africa_comment).id }
        ensure_flash(/comment successfully removed/i)
      end
    end      

    should "be able to delete comment on group he created (js)" do
      assert_difference "Comment.count", -1 do
        delete :destroy, { :id => comments(:africa_comment).id, :format => 'js' }
      end
    end

    should "be able to delete comment his profile" do
      assert_difference "Comment.count", -1 do
        delete :destroy, { :id => comments(:quentin_profile_comment).id }
        ensure_flash(/comment successfully removed/i)
      end
    end

  end

  def self.should_be_able_to_create_comments
    should " be able to create a user comment" do
      assert_difference "Comment.count" do
        post :create, { :type => 'User', :id => users(:quentin).id, :format => 'js', :comment => {:comment => 'test'} }
      end
    end

    should "be able to create a news item comment" do
      assert_difference "Comment.count" do
        post :create, { :type => 'NewsItem', :id => news_items(:one).id, :format => 'js', :comment => {:comment => 'test'} }
      end
    end

    should "be able to create a group comment" do
      assert_difference "Comment.count" do
        post :create, { :type => 'Group', :id => groups(:africa).id, :format => 'js', :comment => {:comment => 'test'} }
      end
    end

    should "not create an empty comment" do
      assert_no_difference "Comment.count" do
        post :create, { :type => 'User', :id => users(:quentin).id, :format => 'js', :comment => {:comment => ''} }
      end
    end
  end

  context "not logged in" do

    should "not allow comment" do
      assert_no_difference "Comment.count" do
        post :create, { :type => 'User', :id => users(:quentin).id, :format => 'js', :comment => {:comment => 'test'} }
        assert_response 406
      end
    end

    should "not be able to delete quentin's comment" do
      assert_no_difference "Comment.count" do
        delete :destroy, { :id => comments(:quentins_comment).id }
      end
    end

  end

  context "logged in as admin" do

    setup do
      login_as :admin
    end

    should_be_able_to_delete_comments
    should_be_able_to_create_comments

  end

  context "aaron, not a member of a group" do

    setup do
      login_as :aaron
    end

    should "not be able to create a comment" do
      assert_no_difference "Comment.count" do
        post :create, { :type => 'Group', :id => groups(:africa).id, :format => 'js', :comment => {:comment => 'test'} }
      end
    end

    should "be able to comment on quentin's blog" do
      assert_difference "Comment.count" do
        quentin = users(:quentin)
        news_item = quentin.blogs.first
        post :create, { :type => 'NewsItem', :id => news_item.id, :format => 'js', :comment => {:comment => 'test'} }
      end
    end

    should "not be able to delete quentin's comment" do
      assert_no_difference "Comment.count" do
        delete :destroy, { :id => comments(:quentins_comment).id }
      end
    end 

  end

  context "quentin logged in" do

    setup do
      login_as :quentin
    end

    should_be_able_to_create_comments
    should_be_able_to_delete_comments
  end

end
