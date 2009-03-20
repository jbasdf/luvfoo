require File.dirname(__FILE__) + '/../test_helper'

class CountryTest < ActiveSupport::TestCase  
  should_have_many :users
end
