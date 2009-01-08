require File.dirname(__FILE__) + '/../test_helper'

class MembershipRequestTest < ActiveSupport::TestCase

    context 'A membership instance' do
        should_belong_to :user
        should_belong_to :group
    end
    
    def test_associations
        _test_associations
    end
    
end
