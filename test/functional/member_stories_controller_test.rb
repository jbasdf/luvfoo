require File.dirname(__FILE__) + '/../test_helper'

class MemberStoriesControllerTest < ActionController::TestCase

  def setup
    @controller = MemberStoriesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @member_story = news_items(:member_story)
  end

  context 'all users' do

    context "GET index" do
      setup do
        get :index
      end
      should_respond_with :success
      should_render_template :index
    end

    context "GET show" do
      setup do
        get :show, :id => @member_story.to_param
      end
      should_respond_with :success
      should_render_template :show
    end

  end
end