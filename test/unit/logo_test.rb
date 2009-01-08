require File.dirname(__FILE__) + '/../test_helper'

class LogoTest < ActiveSupport::TestCase

  context "An logo instance" do
    should_belong_to :user
    should_belong_to :site
  end
  
  def test_associations
    _test_associations
  end

end
