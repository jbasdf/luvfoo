require File.dirname(__FILE__) + '/../test_helper'

class FeedItemTest < ActiveSupport::TestCase

  should_belong_to :creator
  
  def test_associations
    _test_associations
  end

end
