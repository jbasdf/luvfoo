require File.dirname(__FILE__) + '/../../test_helper'

class Groups::ActivitiesControllerTest < Test::Unit::TestCase


  def setup
    @controller = Groups::ActivitiesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  context 'on GET to :index while not logged in' do
    setup do
      get :index, { :group_id => groups(:africa).to_param }
    end

    should_respond_with :success
    should_render_template :index
    should_not_set_the_flash
  end

end
