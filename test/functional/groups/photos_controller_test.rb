require File.dirname(__FILE__) + '/../../test_helper'

class Groups::PhotosControllerTest < Test::Unit::TestCase

  VALID_PHOTO = {
    :image => ActionController::TestUploadedFile.new(File.join(RAILS_ROOT, 'public/images/avatar_default_big.png'), 'image/png')
  }

  def setup
    @controller = Groups::PhotosController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  context 'on GET to :index while not logged in' do
    setup do
      get :index, { :group_id => groups(:africa).to_param }
    end

    should_assign_to :user
    should_assign_to :photos
    should_respond_with :success
    should_render_template :index
    should_not_set_the_flash
    should "not render the upload form" do
      assert_no_tag :tag => 'form', :attributes => { :action => group_photos_path(assigns(:group)) }
    end
  end

  context 'on GET to :index while logged in as group member' do
    setup do
      login_as :africa_member
      get :index, { :group_id => groups(:africa).to_param }
    end

    should_assign_to :user
    should_assign_to :photos
    should_respond_with :success
    should_render_template :index
    should_not_set_the_flash
    should "render the upload form" do
      assert_tag :tag => 'form', :attributes => {:action => group_photos_path(assigns(:group))}
    end
  end

  context 'on GET to :index while logged in as group creator' do
    setup do
      login_as :quentin
      get :index, { :group_id => groups(:africa).to_param }
    end

    should_assign_to :user
    should_assign_to :photos
    should_respond_with :success
    should_render_template :index
    should_not_set_the_flash
    should "render the upload form" do
      assert_tag :tag => 'form', :attributes => {:action => group_photos_path(assigns(:group))}
    end
  end

  context 'on GET to :index while logged in as admin' do
    setup do
      login_as :admin
      get :index, { :group_id => groups(:africa).to_param }
    end

    should_assign_to :user
    should_assign_to :photos
    should_respond_with :success
    should_render_template :index
    should_not_set_the_flash
    should "render the upload form" do
      assert_tag :tag => 'form', :attributes => {:action => group_photos_path(assigns(:group))}
    end
  end

  context 'on GET to :index while logged in as :user' do
    setup do
      login_as :aaron
      get :index, {:group_id => groups(:africa).to_param}
    end

    should_assign_to :user
    should_assign_to :photos
    should_respond_with :success
    should_render_template :index
    should_not_set_the_flash
    should "not render the upload form" do
      assert_no_tag :tag => 'form', :attributes => {:action => group_photos_path(assigns(:group))}
    end
  end

  context 'on GET to :show' do
    setup do
      get :show, {:group_id => groups(:africa).to_param, :id => photos(:first)}
    end

    should_respond_with :redirect
    should_redirect_to 'group_photos_path(groups(:africa))'
    should_not_set_the_flash
  end

  context 'on DELETE to :destroy while logged in as member' do
    setup do
      login_as :africa_member
      assert_no_difference "Photo.count" do
        delete :destroy, {:group_id => groups(:africa).to_param, :id => photos(:first)}
      end
    end

    should_respond_with :redirect
    should_redirect_to 'group_photos_path(groups(:africa))'
    should_set_the_flash_to 'You don\'t have permission to delete that photo.'
  end

  context 'on DELETE to :destroy while logged in as manager' do
    setup do
      login_as :africa_manager
      assert_difference "Photo.count", -1 do
        delete :destroy, {:group_id => groups(:africa).to_param, :id => photos(:first)}
      end
    end

    should_respond_with :redirect
    should_redirect_to 'group_photos_path(groups(:africa))'
    should_set_the_flash_to 'Photo was deleted.'
  end

  context 'on DELETE to :destroy while logged in as creator' do
    setup do
      login_as :quentin
      assert_difference "Photo.count", -1 do
        delete :destroy, {:group_id => groups(:africa).to_param, :id => photos(:first)}
      end
    end

    should_respond_with :redirect
    should_redirect_to 'group_photos_path(groups(:africa))'
    should_set_the_flash_to 'Photo was deleted.'
  end

  context 'on DELETE to :destroy while logged in as admin' do
    setup do
      login_as :admin
      assert_difference "Photo.count", -1 do
        delete :destroy, {:group_id => groups(:africa).to_param, :id => photos(:first)}
      end
    end

    should_respond_with :redirect
    should_redirect_to 'group_photos_path(groups(:africa))'
    should_set_the_flash_to 'Photo was deleted.'
  end

  context 'on DELETE to :destroy while logged in, but not a member' do
    setup do
      login_as :aaron
      assert_no_difference "Photo.count" do
        delete :destroy, {:group_id => groups(:africa).to_param, :id => photos(:first)}
      end
    end

    should_respond_with :redirect
    should_redirect_to 'group_photos_path(groups(:africa))'
    should_set_the_flash_to "You don\'t have permission to delete that photo."
  end

  context 'on DELETE to :destroy while not logged in' do
    setup do
      assert_no_difference "Photo.count" do
        delete :destroy, {:group_id => groups(:africa).to_param, :id => photos(:first)}
      end
    end

    should_respond_with :redirect
    should_redirect_to 'login_path'
    should_set_the_flash_to /You must be logged in to access this feature/i
  end

  context 'on POST to :create with good data while logged in as member' do
    setup do
      login_as :quentin
      assert_difference "Photo.count" do
        post :create, {:group_id => groups(:africa).to_param, :photo => VALID_PHOTO}
      end
    end

    should_respond_with :redirect
    should_redirect_to 'group_photos_path(groups(:africa))'
    should_set_the_flash_to 'Photo successfully uploaded.'
  end

  context 'on POST to :create with bad data while logged in as member' do
    setup do
      login_as :quentin
      assert_no_difference "Photo.count" do
        post :create, {:group_id => groups(:africa).to_param, :photo => {:image => ''}}
      end
    end

    should_respond_with :success
    should_render_template 'index'
  end

  context 'on POST to :create while logged in, but not a member' do
    setup do
      assert_no_difference "Photo.count" do
        post :create, {:group_id => groups(:africa).to_param, :id => photos(:first)}, {:user => users(:aaron).id}
      end
    end

    should_respond_with :redirect
    should_redirect_to 'login_path'
  end

  context 'on POST to :create while logged not in' do
    setup do
      assert_no_difference "Photo.count" do
        post :create, {:group_id => groups(:africa).to_param, :id => photos(:first)}
      end
    end

    should_respond_with :redirect
    should_redirect_to 'login_path'
  end

end
