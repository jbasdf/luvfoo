require File.dirname(__FILE__) + '/../test_helper'

class NewsItemTest < ActiveSupport::TestCase

  context "A NewsItem instance" do

    setup do
      @news_item = news_items(:blog_post)
    end

    should_belong_to :newsable
    should_require_attributes :title, :body
    should_whitelist :body, :title

    context "quentin" do
      should "be able to edit" do
        assert @news_item.can_edit?(users(:quentin))
      end
    end

    context "aaron" do
      should "not be able to edit" do
        assert !@news_item.can_edit?(users(:aaron))
      end
    end

  end

end
