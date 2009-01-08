require File.dirname(__FILE__) + '/../test_helper'

class ModeratorshipTest < Test::Unit::TestCase
  
  context "A Moderatorship instance" do
    
    should_belong_to :forum
    should_belong_to :user
     
    should "find moderators" do
      assert_models_equal [users(:sam)], forums(:rails).moderators
    end
  
    should "find moderated forums" do
      assert_models_equal [forums(:rails)], users(:sam).forums
    end
  
    should "add moderator" do
      assert_equal [], forums(:comics).moderators
      assert_difference "Moderatorship.count" do
        forums(:comics).moderators << users(:sam)
      end
      assert_models_equal [users(:sam)], forums(:comics).moderators(true)
    end
  
    should "not add duplicate moderator" do
      assert_models_equal [users(:sam)], forums(:rails).moderators
      assert_no_difference "Moderatorship.count" do
        assert_raise ActiveRecord::RecordNotSaved do 
          forums(:rails).moderators << users(:sam)
        end
      end
    end
  
  end
  
end
