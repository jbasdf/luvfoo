require File.dirname(__FILE__) + '/../test_helper'

class MessageTest < ActiveSupport::TestCase

  context 'An shared upload instance' do
    should_require_attributes :subject, :body, :sender, :receiver
    should_belong_to :sender
    should_belong_to :receiver
  
    should 'create a message' do
      sender = Factory(:user)
      receiver = Factory(:user)
      assert_difference "Message.count" do
        assert_difference "FeedItem.count" do
          @message = Factory(:message, :sender => sender, :receiver => receiver)
        end
      end  
      assert sender.sent_messages.include?(@message)
      assert receiver.received_messages.include?(@message)
      assert receiver.unread_messages.include?(@message)
      
    end
    
  end
  
  def test_associations
    _test_associations
  end
  
end
