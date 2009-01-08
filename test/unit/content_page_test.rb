require File.dirname(__FILE__) + '/../test_helper'

class ContentPageTest < ActiveSupport::TestCase

  should_have_named_scope :by_newest
  should_have_named_scope :by_alpha
  should_have_named_scope :by_parent
    
  context "content page instance" do
    
    setup do
      @quentin = Factory(:user)
      @aaron = Factory(:user)      
      @page = Factory(:content_page, :creator => @quentin)
    end
    
    should_whitelist :body, :title
    should_require_attributes :body_raw, :title
    should_belong_to :contentable

    context "quentin" do
      should "be able to edit" do
        assert @page.can_edit?(@quentin)
      end
    end

    context "aaron" do
      should "not be able to edit" do
        assert !@page.can_edit?(@aaron)
      end
    end

  end

  context "create new page" do
    
    should "create a page" do
      page = Factory(:content_page)
    end
    
    should "edit the page link" do
      page = Factory(:content_page, :title => 'the life and times')
      assert page.url_key == 'the-life-and-times'
      page.update_attributes!(:url_key => 'life')
      
      page.update_attributes!(:url_key => 'life time')
      assert page.url_key == 'life-time'
    end
    
  end
  
  context "tag page" do
    
    should "tag page with 'test'" do
      page = Factory(:content_page)
      assert page.update_attributes!(:tag_list => 'test')
    end
    
    should "add 'menu tag' to page" do
      page = Factory(:content_page)
      tag = 'home page menu'
      assert page.update_attributes!(:menu_list => tag)
      assert ContentPage.tagged_with(tag, :on => :menus)
    end
    
  end
  

  def test_associations
    _test_associations
  end

end
