require File.dirname(__FILE__) + '/../test_helper'

class CountryTest < ActiveSupport::TestCase
    
    should_have_many :users
    
    def test_associations
        _test_associations
    end
    
end
