require File.dirname(__FILE__) + '/../test_helper'

class CommentTest < ActiveSupport::TestCase

  context 'A Comment instance' do
    should_belong_to :commentable
    should_belong_to :user
    
    should_have_named_scope :recent
    
  end

  should "show me the wall between us" do
    comments = Comment.between_users users(:quentin), users(:aaron)
    assert_equal 1, comments.size
    assert_equal [comments(:third).id], comments.map(&:id).sort

    assert users(:quentin).comments.create(:comment => 'new comment', :user => users(:aaron))
    assert_equal 2, Comment.between_users( users(:quentin), users(:aaron)).size
  end

  should "show me the wall between me" do
    comments = Comment.between_users users(:quentin), users(:quentin)
    assert_equal 1, comments.size
    assert_equal [comments(:seven).id], comments.map(&:id).sort
  end

  should "get recent comments" do
    comments = Comment.recent
    assert comments.size > 0
  end

  should 'create new feed_item and feeds after someone else creates a comment' do
    assert_difference "FeedItem.count", 1 do
      assert_difference "Feed.count", 3 do
        user = users(:quentin)
        assert user.comments.create(:comment => 'a new comment', :user_id => users(:aaron).id)
      end
    end
  end

  context "comments" do

    setup do
      @quentin = users(:quentin)
      @aaron = users(:aaron)
      @test_guy = users(:test_guy)
      @group = groups(:africa)
      @africa_member = users(:africa_member) 
      @africa_member_too = users(:africa_member_too)
      @admin = users(:admin)  
      @africa_manager = users(:africa_manager)         
    end

    context "both aaron and quentin" do

      should "be able to edit a comment made on Aaron's profile by Quentin" do
        comment = @aaron.comments.create(:comment => 'hi Aaron', :user_id => @quentin.id)
        assert comment.can_edit?(@quentin)
        assert comment.can_edit?(@aaron)            
      end

      should "be able to edit a comment made on Aaron's blog post by Quentin" do
        blog_post = Factory(:news_item, :newsable => @aaron, :creator => @aaron)
        comment = blog_post.comments.create(:comment => 'hi Aaron', :user_id => @quentin.id)
        assert comment.can_edit?(@quentin)
        assert comment.can_edit?(@aaron)            
      end

    end

    context "made on group news item by africa member" do

      setup do
        group_news_item = Factory(:news_item, :newsable => @group, :creator => @quentin)
        @comment = group_news_item.comments.create(:comment => 'comment on group news', :user_id => @africa_member.id)
      end

      should "be editable by quentin as a group creator" do
        assert @comment.can_edit?(@quentin), "Group creator can't edit comments"
      end

      should "be editable by site admin" do
        assert @comment.can_edit?(@admin), "Admin can't edit comments"
      end

      should "be editable by group manager" do
        assert @comment.can_edit?(@africa_manager), "Africa group manager can't edit comments"
      end

      should "be editable by comment poster" do
        assert @comment.can_edit?(@africa_member), "Comment poster can't edit comment"
      end

      should "not be editable by group members that did not make the comment" do
        assert !@comment.can_edit?(@africa_member_too), "Group member that didn't make comment can edit comments"
      end

      should "not be editable by non group members" do
        assert !@comment.can_edit?(@aaron), "Aaron can edit comments"
      end

    end


  end

  def test_associations
    _test_associations
  end

end