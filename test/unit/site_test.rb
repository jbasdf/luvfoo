require 'test_helper'

class SiteTest < ActiveSupport::TestCase

  context "A site instance" do
    should_have_many :news_items        
    should_have_many :pages
    should_have_many :uploads
    
    should_have_one :logo
  end

end
