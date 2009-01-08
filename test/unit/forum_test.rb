require File.dirname(__FILE__) + '/../test_helper'

class ForumTest < ActiveSupport::TestCase

  context "A forum instance" do
    should_require_attributes :name
    
    should_have_many :moderatorships
    should_have_many :moderators, :through => :moderatorships
    should_have_many :topics
    should_have_one  :recent_topic
    should_have_many :recent_topics
    should_have_many :posts
    should_have_one  :recent_post
    
    should_have_named_scope :by_newest
    should_have_named_scope :recent
    should_have_named_scope :by_position
    should_have_named_scope :site_forums
        
    context ".build_topic" do
      should "return a Topic" do
        forum = Factory(:forum)
        topic = Factory(:topic, :forum => forum)
        assert_kind_of Topic, topic
        assert_equal forum, topic.forum
      end
    end

    should "list only top level topics" do
      assert_models_equal [topics(:sticky), topics(:il8n), topics(:ponies), topics(:pdi)], forums(:rails).topics
    end
    
    should "list recent posts" do
      assert_models_equal [posts(:il8n), posts(:ponies), posts(:pdi_rebuttal), posts(:pdi_reply), posts(:pdi),posts(:sticky) ], forums(:rails).posts
    end
   
    should "find recent post" do
      assert_equal posts(:il8n), forums(:rails).recent_post
    end
    
    should "find recent topic" do
      assert_equal topics(:il8n), forums(:rails).recent_topic
    end
    
    should "find first recent post" do
      assert_equal topics(:il8n), forums(:rails).recent_topic
    end
    
    should "format body html" do
      forum = Forum.new(:description => 'foo')
      forum.send :format_content
      assert_not_nil forum.description_html
    
      forum.description = ''
      forum.send :format_content
      assert forum.description_html.blank?
    end
    
    should "find ordered forums" do
      assert_equal [forums(:comics), forums(:rails), forums(:africa)], Forum.by_position
    end
     
  end

  def test_associations
    _test_associations
  end

end