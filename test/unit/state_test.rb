require File.dirname(__FILE__) + '/../test_helper'

class StateTest < ActiveSupport::TestCase

    context "A state instance" do
        should_have_many :users
        should_belong_to :country
    end

end
