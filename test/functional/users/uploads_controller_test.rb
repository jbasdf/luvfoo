require File.dirname(__FILE__) + '/../../test_helper'

class Users::UploadsControllerTest < Test::Unit::TestCase

  VALID_FILE = ActionController::TestUploadedFile.new(File.join(RAILS_ROOT, 'public/images/avatar_default_big.png'), 'image/png')

  def setup
    @controller = Users::UploadsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @uploads_created = 6
  end

  context 'not logged in' do

    context "GET index" do
      setup do
        get :index, { :user_id => users(:quentin).to_param }
      end

      should_respond_with :redirect
      should_redirect_to 'login_path'
      should_set_the_flash_to NOT_LOGGED_IN_MSG
    end

  end

  context 'logged in as user' do
    setup do
      login_as :aaron
      @user = users(:aaron)
    end

    context "GET index" do
      setup do
        get :index, { :user_id => users(:quentin).to_param }
      end
      should_respond_with :success
      should_render_template 'index'
    end

    context "GET photos" do
      setup do
        get :photos, { :user_id => users(:quentin).to_param }
      end
      should_respond_with :success
      should_render_template 'photos'
    end

    context "GET files (js)" do
      setup do
        get :files, { :user_id => users(:quentin).to_param, :format => 'js' }
      end
      should_respond_with :success
    end

    context "GET images (js)" do
      setup do
        get :images, { :user_id => users(:quentin).to_param, :format => 'js' }
      end
      should_respond_with :success
    end

  end

  context 'logged in as owner' do
    setup do
      @caption = '1234find'
      @user = users(:quentin)
      login_as :quentin
    end

    context "GET index" do
      setup do
        get :index, { :user_id => users(:quentin).to_param }
      end

      should_respond_with :success
      should_render_template 'index'
    end

  end

end
