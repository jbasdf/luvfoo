require File.dirname(__FILE__) + '/../../test_helper'

class Admin::MemberStoriesControllerTest < ActionController::TestCase

  def setup
    @controller =  Admin::MemberStoriesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @news_item  = news_items(:member_story)
  end

  should_require_login :index, :show, :new, :create, :edit, :update, :destroy

  context "logged in as user" do
    setup do
      login_as users(:aaron).login
    end
    should_require_login :index, :show, :new, :create, :edit, :update, :destroy
  end

  context "logged in as admin" do
    setup do
      login_as users(:admin).login
    end
    
    context "get index" do
      setup do
        get :index
      end
      should_respond_with :success
    end
    
    context "get index (js)" do
      setup do
        get :index, :format => 'json'
      end
      should_respond_with :success
    end
    
    should_be_restful do |resource|
      resource.klass      = NewsItem
      resource.object     = :news_item
      resource.formats    = [:html]
      resource.update.redirect  = "admin_member_stories_url"
      resource.create.redirect  = "admin_member_stories_url" 
      resource.destroy.redirect = "admin_member_stories_url"
      resource.create.flash  = /created/i
      resource.update.flash  = /updated/i
      resource.destroy.flash = /deleted/i
      resource.create.params = { :title => "news story title", :body => "this is the body of the news story" }
      resource.update.params = { :title => "new title" }
    end
  end

end
