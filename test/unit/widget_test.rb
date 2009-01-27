require 'test_helper'

class WidgetTest < ActiveSupport::TestCase

  context "A widget instance" do
    should_have_many :news_items        
    should_have_many :feeds
    should_have_many :feed_items
    should_have_many :uploads
  end

end
