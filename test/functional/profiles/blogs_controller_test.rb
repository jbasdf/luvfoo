require File.dirname(__FILE__) + '/../../test_helper'

class Profiles::BlogsControllerTest < Test::Unit::TestCase

  def setup
    @controller = Profiles::BlogsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @user       = users(:quentin)
    @news_item  = news_items(:blog_post)
  end

  context "all users" do

    context "GET index" do
      setup do
        get :index, :profile_id => @user.to_param
      end
      should_respond_with :success
      should_render_template :index
    end

    context "GET show" do
      setup do
        get :show, :profile_id => @user.to_param, :id => @news_item.to_param
      end
      should_respond_with :success
      should_render_template :show
    end
  end

end