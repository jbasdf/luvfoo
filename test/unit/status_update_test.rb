require File.dirname(__FILE__) + '/../test_helper'

class StatusUpdateTest < ActiveSupport::TestCase

  context 'A StatusUpdate instance' do
    
    should_have_many :comments
    should_have_many :feed_items
    
    should_belong_to :user
    should_have_named_scope :recent
    
    should 'update a users status' do
      user = Factory(:user)
      assert_difference "StatusUpdate.count" do
        assert_difference "FeedItem.count" do
          @status_update = Factory(:status_update, :user => user)
        end
      end  
      assert user.status == @status_update
    end
        
    should 'delete a users status' do
      user = Factory(:user)
      @status_update = Factory(:status_update, :user => user)
      assert_difference "StatusUpdate.count", -1 do
        assert_difference "FeedItem.count", -1 do
          @status_update.destroy
        end
      end  
    end
    
  end
  
end
