require File.dirname(__FILE__) + '/../test_helper'

class SharedEntryTest < ActiveSupport::TestCase

    context 'An shared entry instance' do
        should_belong_to :entry
        should_belong_to :shared_by
        should_have_many :comments
    end
    
    def test_associations
        _test_associations
    end
    
end
