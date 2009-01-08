require File.dirname(__FILE__) + '/../test_helper'

class SharedUploadsControllerTest < Test::Unit::TestCase


  def setup
    @controller = SharedUploadsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  context 'not logged in' do

    # context "GET new" do
    #       setup do
    #         get :new
    #       end
    # 
    #       should_respond_with :redirect
    #       should_redirect_to 'login_path'
    #       should_set_the_flash_to NOT_LOGGED_IN_MSG
    #     end
    # 
    #     context 'on POST to :create while logged not in' do
    #       setup do
    #         assert_no_difference "SharedUpload.count" do
    #           post :create
    #         end
    #       end
    # 
    #       should_respond_with :redirect
    #       should_redirect_to 'login_path'
    #       should_set_the_flash_to NOT_LOGGED_IN_MSG
    #     end
    # 
    #     context 'on DELETE to :destroy' do
    #       setup do
    #         assert_no_difference "SharedUpload.count" do
    #           delete :destroy
    #         end
    #       end
    # 
    #       should_respond_with :redirect
    #       should_redirect_to 'login_path'
    #       should_set_the_flash_to NOT_LOGGED_IN_MSG
    #     end

  end

  context 'logged in as aaron' do
    setup do
      login_as :aaron
      @user = users(:aaron)
    end

    context 'on POST to :create' do
      setup do
        assert_difference "SharedUpload.count", 1 do
          post :create, {:user_id => users(:quentin).to_param, :upload_id => uploads(:aaron_upload).id, :public => 'on', :friend_ids => {users(:quentin).id => '1'}, :group_ids => {groups(:africa).id => '1'}}
        end
      end

      should "not share with africa group" do
        assert_nil SharedUpload.find_by_shared_by_id_and_shared_uploadable_id(@user.id, groups(:africa).id)
      end

      should_respond_with :redirect
      should_redirect_to 'user_uploads_path(@user)'
      should_set_the_flash_to(/File was successfully shared/i)
    end

    context "trying to share quentin's upload" do
      setup do
        assert_no_difference "SharedUpload.count" do
          post :create, {:user_id => users(:quentin).to_param, :upload_id => uploads(:first).id, :public => 'on', :friend_ids => {users(:quentin).id => '1'}, :group_ids => {groups(:africa).id => '1'}}
        end
      end

      should "not share with africa group" do
        assert_nil SharedUpload.find_by_shared_by_id_and_shared_uploadable_id(@user.id, groups(:africa).id)
      end

      should_respond_with :redirect
      should_redirect_to 'user_uploads_path(@user)'
      should_set_the_flash_to(/File was successfully shared/i)
    end

    context 'on DELETE to :destroy' do
      setup do
        assert_difference "SharedUpload.count", -1 do
          delete :destroy, {:id => shared_uploads(:shared_by_aaron_to_quentin)}
        end
      end

      should_set_the_flash_to(/Deleted shared file/i)
    end

  end

  context 'logged in as quentin' do
    setup do
      login_as :quentin
      @user = users(:quentin)
    end

    context "GET new" do
      setup do
        get :new, { :user_id => users(:quentin).to_param, :upload_id => uploads(:first) }
      end

      should_respond_with :success
      should_render_template 'new'
    end

    context "GET index" do
      setup do
        get :index, { :user_id => users(:quentin).to_param }
      end

      should_respond_with :success
      should_render_template 'index'
    end

    context "GET for_me" do
      setup do
        get :for_me, { :user_id => users(:quentin).to_param }
      end

      should_respond_with :success
      should_render_template 'for_me'
    end

    context "GET for_group" do
      setup do
        get :for_group, { :group_id => groups(:africa).to_param }
      end

      should_respond_with :success
      should_render_template 'for_group'
    end

    context 'on POST to :create' do
      setup do
        assert_difference "SharedUpload.count", 2 do
          post :create, {:user_id => users(:quentin).to_param, :upload_id => uploads(:first).id, :public => 'on', :friend_ids => {users(:aaron).id => '1'}, :group_ids => {groups(:africa).id => '1'}}
        end
      end

      should "create a new record" do
        assert SharedUpload.find_by_shared_by_id_and_shared_uploadable_id(@user.id, groups(:africa).id)
      end

      should_respond_with :redirect
      should_redirect_to 'user_uploads_path(@user)'
      should_set_the_flash_to(/File was successfully shared/i)
    end

    context 'on DELETE to :destroy' do
      setup do
        assert_difference "SharedUpload.count", -1 do
          delete :destroy, {:id => shared_uploads(:shared_by_aaron_to_quentin)}
        end
      end

      should_set_the_flash_to(/Deleted shared file/i)
    end

  end

end