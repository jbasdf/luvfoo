require File.dirname(__FILE__) + '/../test_helper'

class TopicTest < Test::Unit::TestCase
  
  context "a Topic instance" do
    
    should "save and update post_id for posts belonging to topic" do
      # checking current forum_id's are in sync
      topic = topics(:pdi)
      post_forums = lambda do
        topic.posts.each { |p| assert_equal p.forum_id, topic.forum_id }
      end
      post_forums.call
      assert_equal forums(:rails).id, topic.forum_id
    
      # updating forum_id
      topic.update_attribute :forum_id, forums(:comics).id
      assert_equal forums(:comics).id, topic.reload.forum_id
      post_forums.call
    end

    should "know last post" do
      assert_equal posts(:pdi_rebuttal), topics(:pdi).last_post
    end

    should "ensure counts are valid" do
      assert_equal forums(:rails).topics_count, forums(:rails).topics.size
      assert_equal forums(:comics).topics_count, forums(:comics).topics.size
    end
  
    should "move topic to different forum preserves counts" do
      rails = lambda { [forums(:rails).topics_count, forums(:rails).posts_count] }
      comics = lambda { [forums(:comics).topics_count, forums(:comics).posts_count] }
      old_rails = rails.call
      old_comics = comics.call
    
      topics(:il8n).posts.each { |post| post.forum==forums(:rails) }
    
      @topic=topics(:il8n)
      @topic.forum=forums(:comics)
      @topic.save!
    
      topics(:il8n).posts.each { |post| post.forum==forums(:comics) }
    
      forums(:rails).reload
      forums(:comics).reload
  
      assert_equal old_rails.collect { |n| n - 1}, rails.call
      assert_equal old_comics.collect { |n| n + 1}, rails.call
    end
  
    should "test voices" do
      @pdi=topics(:pdi)
      post=@pdi.posts.build(:body => "test")
      post.user_id=users(:joe).id
      post.save!
      post=@pdi.posts.build(:body => "test")
      post.user_id=users(:kyle).id
      post.save!
      @pdi.reload
      assert_equal 5, @pdi.posts.count      
      assert_equal [users(:aaron).id, users(:kyle).id, users(:joe).id, users(:sam).id], @pdi.voices.map(&:id).sort
      assert_equal 4, @pdi.voices.size
    end
  
    should "require title user and forum" do
      t=Topic.new
      t.valid?
      assert t.errors.on(:title)
      assert t.errors.on(:user)
      assert t.errors.on(:forum)
      assert ! t.save
      t.user  = users(:aaron)
      t.title = "happy life"
      t.forum = forums(:rails)
      assert t.save
      assert_nil t.errors.on(:title)
      assert_nil t.errors.on(:user)
      assert_nil t.errors.on(:forum)
    end

    should "add to user counter cache" do
      assert_difference "Post.count" do
        assert_difference "users(:sam).posts.count" do
          p = topics(:pdi).posts.build(:body => "I'll do it")
          p.user = users(:sam)
          p.save
        end
      end
    end

    should "create topic" do
      counts = lambda { [Topic.count, forums(:rails).topics_count] }
      old = counts.call
      t = forums(:rails).topics.build(:title => 'foo')
      t.user = users(:aaron)
      assert_valid t
      t.save
      assert_equal 0, t.sticky
      [forums(:rails), users(:aaron)].each &:reload
      assert_equal old.collect { |n| n + 1}, counts.call
    end
  
    should "delete topic and update the cache" do
      counts = lambda { [Topic.count, Post.count, forums(:rails).topics_count, forums(:rails).posts_count,  users(:sam).posts_count] }
      old = counts.call
      topics(:ponies).destroy
      [forums(:rails), users(:sam)].each &:reload
      assert_equal old.collect { |n| n - 1}, counts.call
    end
  
    should "test hits" do
      hits=topics(:pdi).views
      topics(:pdi).hit!
      topics(:pdi).hit!
      assert_equal(hits+2, topics(:pdi).reload.hits)
      assert_equal(topics(:pdi).hits, topics(:pdi).views)
    end
  
    should "test replied at set" do
      t=Topic.new
      t.user=users(:aaron)
      t.title = "happy life"
      t.forum = forums(:rails)
      assert t.save
      assert_not_nil t.replied_at
      assert t.replied_at <= Time.now.utc
      assert_in_delta t.replied_at, Time.now.utc, 5.seconds
    end
  
    should "test doesnt change replied at on save" do
      t=Topic.find(:first)
      old=t.replied_at
      assert t.save
      assert_equal old, t.replied_at
    end
  
    should "return_correct_last_page" do
      t = Topic.new
      t.posts_count = 51
      assert_equal 3, t.last_page
      t.posts_count = 26
      assert_equal 2, t.last_page
      t.posts_count = 1
      assert_equal 1, t.last_page
      t.posts_count = 0
      assert_equal 1, t.last_page
    end
    
  end
end
