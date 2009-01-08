require File.dirname(__FILE__) + '/../test_helper'

class PhotoTest < ActiveSupport::TestCase

    context "A Photo instance" do
        should_belong_to :photoable
        should_require_attributes :image
    end

end