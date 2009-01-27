require File.dirname(__FILE__) + '/../test_helper'

class EventUserTest < ActiveSupport::TestCase

  context 'A EventUser instance' do
    
    should_belong_to :event
    should_belong_to :user
    
    should_have_named_scope :current_events_for
    
  end
  
end