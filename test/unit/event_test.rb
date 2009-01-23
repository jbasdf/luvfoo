require File.dirname(__FILE__) + '/../test_helper'

class EventTest < ActiveSupport::TestCase

  context 'A Event instance' do
    should_belong_to :eventable
    should_belong_to :user
    
    should_require_attributes :user, :title, :start_at
    
  end
  
  
end