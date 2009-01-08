require File.dirname(__FILE__) + '/../test_helper'

class MonitorshipTest < Test::Unit::TestCase
  
  context "A Moderatorship instance" do
    
    should_belong_to :user
    should_belong_to :topic
    
    should "find monitorships from users" do
      assert_models_equal [monitorships(:aaron_pdi)], users(:aaron).monitorships
      assert_models_equal [monitorships(:sam_pdi)],   users(:sam).monitorships
    end
  
    should "find monitorships from topics" do
      assert_models_equal [monitorships(:sam_pdi), monitorships(:aaron_pdi)], topics(:pdi).monitorships
    end
  
    should "find active watchers" do
      assert_models_equal [users(:aaron)], topics(:pdi).monitors
    end

    should "find monitored topics for user" do
      assert_models_equal [topics(:pdi)], users(:aaron).monitored_topics
    end
  
    should "not find inactive monitored topics" do
      assert_equal [], users(:sam).monitored_topics
    end
  
    should "not find any monitored topics" do
      assert_equal [], users(:joe).monitored_topics
    end
  
  end

end
