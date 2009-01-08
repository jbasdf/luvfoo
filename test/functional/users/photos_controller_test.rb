require File.dirname(__FILE__) + '/../../test_helper'

class Users::PhotosControllerTest < Test::Unit::TestCase

  VALID_PHOTO = {
    :image => ActionController::TestUploadedFile.new(File.join(RAILS_ROOT, 'public/images/avatar_default_big.png'), 'image/png')
  }

  def setup
    @controller = Users::PhotosController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  context 'on GET to :index while not logged in' do
    setup do
      get :index, { :user_id => users(:quentin).to_param }
    end

    should_assign_to :user
    should_assign_to :photos
    should_respond_with :success
    should_render_template :index
    should_not_set_the_flash
    should "not render the upload form" do
      assert_no_tag :tag => 'form', :attributes => { :action => user_photos_path(assigns(:user)) }
    end
  end

  context 'on GET to :index while logged in as :owner' do
    setup do
      login_as :quentin
      get :index, { :user_id => users(:quentin).to_param }
    end

    should_assign_to :user
    should_assign_to :photos
    should_respond_with :success
    should_render_template :index
    should_not_set_the_flash
    should "render the upload form" do
      assert_tag :tag => 'form', :attributes => {:action => user_photos_path(assigns(:user))}
    end
  end

  context 'on GET to :index while logged in as :user' do
    setup do
      login_as :aaron
      get :index, {:user_id => users(:quentin).to_param}
    end

    should_assign_to :user
    should_assign_to :photos
    should_respond_with :success
    should_render_template :index
    should_not_set_the_flash
    should "not render the upload form" do
      assert_no_tag :tag => 'form', :attributes => {:action => user_photos_path(assigns(:user))}
    end
  end

  context 'on GET to :show' do
    setup do
      get :show, {:user_id => users(:quentin).to_param, :id => photos(:first)}
    end

    should_respond_with :redirect
    should_redirect_to 'user_photos_path(users(:quentin))'
    should_not_set_the_flash
  end

  context 'on DELETE to :destroy while logged in as :owner' do
    setup do
      login_as :quentin
      assert_difference "Photo.count", -1 do
        delete :destroy, {:user_id => users(:quentin).to_param, :id => photos(:first)}
      end
    end

    should_respond_with :redirect
    should_redirect_to 'user_photos_path(users(:quentin))'
    should_set_the_flash_to 'Photo was deleted.'
  end

  context 'on DELETE to :destroy while logged in as :user' do
    setup do
      login_as :aaron
      assert_no_difference "Photo.count" do
        delete :destroy, {:user_id => users(:quentin).to_param, :id => photos(:first)}
      end
    end

    should_respond_with :redirect
    should_redirect_to 'user_photos_path(users(:quentin))'
    should_set_the_flash_to "You don\'t have permission to delete that photo."
  end

  context 'on DELETE to :destroy while not logged in' do
    setup do
      assert_no_difference "Photo.count" do
        delete :destroy, {:user_id => users(:quentin).to_param, :id => photos(:first)}
      end
    end

    should_respond_with :redirect
    should_redirect_to 'login_path'
    should_set_the_flash_to /You must be logged in to access this feature/i
  end

  context 'on POST to :create with good data while logged in as :owner' do
    setup do
      login_as :quentin
      assert_difference "Photo.count" do
        post :create, {:user_id => users(:quentin).to_param, :photo => VALID_PHOTO}
      end
    end

    should_respond_with :redirect
    should_redirect_to 'user_photos_path(users(:quentin))'
    should_set_the_flash_to 'Photo successfully uploaded.'
  end

  context 'on POST to :create with bad data while logged in as :owner' do
    setup do
      login_as :quentin
      assert_no_difference "Photo.count" do
        post :create, {:user_id => users(:quentin).to_param, :photo => {:image => ''}}
      end
    end

    should_respond_with :success
    should_render_template 'index'
  end

  context 'on POST to :create while logged in as :user' do
    setup do
      assert_no_difference "Photo.count" do
        post :create, {:user_id => users(:quentin).to_param, :id => photos(:first)}, {:user => users(:aaron).id}
      end
    end

    should_respond_with :redirect
    should_redirect_to 'login_path'
  end

  context 'on POST to :create while logged not in' do
    setup do
      assert_no_difference "Photo.count" do
        post :create, {:user_id => users(:quentin).to_param, :id => photos(:first)}
      end
    end

    should_respond_with :redirect
    should_redirect_to 'login_path'
  end

end
