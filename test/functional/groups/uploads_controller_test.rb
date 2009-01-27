require File.dirname(__FILE__) + '/../../test_helper'

class Groups::UploadsControllerTest < Test::Unit::TestCase

  VALID_FILE = ActionController::TestUploadedFile.new(File.join(RAILS_ROOT, 'public/images/avatar_default_big.png'), 'image/png')

  def setup
    @controller = Groups::UploadsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @uploads_created = 6
  end

  context 'not logged in' do

    context "GET index" do
      setup do
        get :index, { :group_id => groups(:africa).to_param }
      end
      should_respond_with :success
      should_render_template 'index'
    end

    context "GET photos" do
      setup do
        get :photos, { :group_id => groups(:africa).to_param }
      end
      should_respond_with :success
      should_render_template 'photos'
    end

  end

  context 'logged in as group user' do
    setup do
      @user = users(:africa_member)
      login_as @user
    end

    context "GET index" do
      setup do
        get :index, { :group_id => groups(:africa).to_param }
      end
      should_respond_with :success
      should_render_template 'index'
    end

    context "GET photos" do
      setup do
        get :photos, { :group_id => groups(:africa).to_param }
      end
      should_respond_with :success
      should_render_template 'photos'
    end
    
    context "GET files (js)" do
      setup do
        get :files, { :group_id => groups(:africa).to_param, :format => 'js' }
      end
      should_respond_with :success
    end

    context "GET images (js)" do
      setup do
        get :images, { :group_id => groups(:africa).to_param, :format => 'js' }
      end
      should_respond_with :success
    end
    
  end

  context 'logged in as group creator' do
    setup do
      @caption = '1234find'
      @user = users(:quentin)
      login_as @user
    end

    context "GET index" do
      setup do
        get :index, { :group_id => groups(:africa).to_param }
      end
      should_respond_with :success
      should_render_template 'index'
    end
    
  end

end
