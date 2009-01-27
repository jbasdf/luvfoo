require File.dirname(__FILE__) + '/../test_helper'

class EventTest < ActiveSupport::TestCase

  context 'A Event instance' do
    
    should_belong_to :eventable
    should_belong_to :user
    should_have_many :attendees
    should_have_many :event_users
    
    should_require_attributes :user, :title, :start_at
    
  end
  
  context 'creating a new event attendee' do
    
    setup do
      @event = Factory(:event)
      @user = Factory(:user)
    end
    
    should 'increment the attendee counter' do
      @event_user = EventUser.new
      @event_user.event = @event
      @event_user.user = @user
      @event_user.save!
      @event.reload
      assert @event.attendees_count == 1
    end
    
  end
  
end