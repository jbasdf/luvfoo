require File.dirname(__FILE__) + '/../test_helper'

class PostTest < Test::Unit::TestCase
  
  context "A Post instance" do
    
    should "select posts" do
      assert_equal [posts(:pdi), posts(:pdi_reply), posts(:pdi_rebuttal)], topics(:pdi).posts
    end
  
    should "find topic" do
      assert_equal topics(:pdi), posts(:pdi_reply).topic
    end

    should "require body for post" do
      p = topics(:pdi).posts.build
      p.valid?
      assert p.errors.on(:body)
    end

    should "create reply" do
      counts = lambda { [Post.count, forums(:rails).posts_count, users(:admin).posts_count, topics(:pdi).posts_count] }
      equal  = lambda { [forums(:rails).topics_count] }
      old_counts = counts.call
      old_equal  = equal.call
    
      p = create_post topics(:pdi), :body => 'blah'
      assert_valid p

      [forums(:rails), users(:admin), topics(:pdi)].each &:reload
    
      assert_equal old_counts.collect { |n| n + 1}, counts.call
      assert_equal old_equal, equal.call
    end

    should "update cached data" do
      p = create_post topics(:pdi), :body => 'ok, ill get right on it'
      assert_valid p
      topics(:pdi).reload
      assert_equal p.id, topics(:pdi).last_post_id
      assert_equal p.user_id, topics(:pdi).replied_by
      assert_equal p.created_at.to_i, topics(:pdi).replied_at.to_i
    end

    should "delete last post and fix topic cached data" do
      posts(:pdi_rebuttal).destroy
      assert_equal posts(:pdi_reply), topics(:pdi).last_post
      assert_equal posts(:pdi_reply).user_id, topics(:pdi).replied_by
      assert_equal posts(:pdi_reply).created_at.to_i, topics(:pdi).replied_at.to_i
    end
  
    should "delete only remaining post and clear topic" do
      posts(:sticky).destroy
      assert_raises ActiveRecord::RecordNotFound do
        topics(:sticky)
      end
    end

    should "create reply and set forum from topic" do
      p = create_post topics(:pdi), :body => 'blah'
      assert_equal topics(:pdi).forum_id, p.forum_id
    end

    should "delete reply" do
      counts = lambda { [Post.count, forums(:rails).posts_count, users(:sam).posts_count, topics(:pdi).posts_count] }
      equal  = lambda { [forums(:rails).topics_count] }
      old_counts = counts.call
      old_equal  = equal.call
      posts(:pdi_reply).destroy
      [forums(:rails), users(:sam), topics(:pdi)].each &:reload
      assert_equal old_counts.collect { |n| n - 1}, counts.call
      assert_equal old_equal, equal.call
    end

    should "edit own post" do
      assert posts(:shield).editable_by?(users(:sam))
    end

    should "edit post as admin" do
      assert posts(:shield).editable_by?(users(:admin))
    end

    should "edit post as moderator" do
      assert posts(:pdi).editable_by?(users(:sam))
    end

    should "not edit post in own topic" do
      assert !posts(:shield_reply).editable_by?(users(:sam))
    end
  
  end
  
  protected
  def create_post(topic, options = {})
    returning topic.posts.build(options) do |p|
      p.user = users(:admin)
      p.save
      # post should inherit the forum from the topic
      assert_equal p.topic.forum, p.forum
    end
  end

end
