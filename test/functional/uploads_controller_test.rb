require File.dirname(__FILE__) + '/../test_helper'

class UploadsControllerTest < Test::Unit::TestCase

  VALID_FILE = ActionController::TestUploadedFile.new(File.join(RAILS_ROOT, 'public/images/avatar_default_big.png'), 'image/png')

  def setup
    @controller = UploadsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @uploads_created = 6
  end

  should_require_login :index, :create, :destroy, :update, :new, :edit, :show

  context 'logged in as user' do

    setup do
      login_as :aaron
      @user = users(:aaron)
      @site = sites(:default)
    end

    context 'on POST to :create' do

      context "upload a file" do

        setup do
          assert_difference "Upload.count", @uploads_created do
            post :create, {:user_id => @user.to_param, :upload => { :uploaded_data => VALID_FILE }, :type => 'User', :id => @user.id }
          end
        end

        should_respond_with :redirect
        should_redirect_to 'user_uploads_path(@user)'

      end

      context "try to upload using someone else's account" do

        setup do
          assert_difference "Upload.count", @uploads_created do
            post :create, {:user_id => users(:quentin).to_param, :upload => { :uploaded_data => VALID_FILE }, :type => 'User', :id => @user.id }
          end
        end    

        should_respond_with :redirect
        should_redirect_to 'user_uploads_path(@user)'

        should "create file with aaron's id even though it was posted with quentin's" do
          upload = Upload.find(:first, :order => 'created_at DESC')
          assert upload.user_id = @user.id
        end
        
      end

      context "try to upload to the 'site' when not an admin" do

        setup do
          assert_no_difference "Upload.count" do
            post :create, {:user_id => users(:quentin).to_param, :upload => { :uploaded_data => VALID_FILE }, :type => 'Site', :id => @site.id }
          end
        end    

        should_respond_with :redirect
        should_redirect_to 'user_uploads_path(@user)'
        
      end
      
    end

    context 'on POST to :swfupload' do
      setup do
        assert_difference "Upload.count", @uploads_created do
          post :swfupload, {:user_id => users(:quentin).to_param, :Filedata => VALID_FILE, :type => 'User', :id => @user.id }
        end
      end
    
      should_respond_with :success
    
      should "not return 'Error'" do
        assert @response != 'Error'
      end
    end

    context 'on DELETE to :destroy' do
      setup do
        assert_no_difference "Upload.count" do
          delete :destroy, {:user_id => users(:quentin).to_param, :id => uploads(:first)}
        end
      end

      should_respond_with :redirect
      should_redirect_to 'user_uploads_path(users(:aaron))'
      should_set_the_flash_to(/You don't have permission/i)
    end

  end

  context 'logged in as owner' do
    setup do
      @caption = '1234find'
      @user = users(:quentin)
      login_as :quentin
    end

    context 'on POST to :create with good data' do
      setup do
        assert_difference "Upload.count", @uploads_created do
          post :create, {:user_id => users(:quentin).to_param, :upload => { :uploaded_data => VALID_FILE, :caption => @caption }, :type => 'User', :id => @user.id }
        end
      end

      should_respond_with :redirect
      should_redirect_to 'user_uploads_path(users(:quentin))'
      should_set_the_flash_to(/successfully uploaded/i)

      should "create file" do
        upload = Upload.find_by_caption(@caption)
        assert upload.user_id = @user.id
      end

    end

    context 'on POST to :create with bad data' do
      setup do
        assert_no_difference "Upload.count" do
          post :create, {:user_id => users(:quentin).to_param, :upload => { :uploaded_data => '', :caption => @caption }, :type => 'User', :id => @user.id }
        end
      end

      should_respond_with :redirect
      should_redirect_to 'user_uploads_path(users(:quentin))'

      should "not create file" do
        upload = Upload.find_by_caption(@caption)
        assert upload.nil?
      end
    end

    context 'on DELETE to :destroy' do
      setup do
        assert_difference "Upload.count", -1 do
          delete :destroy, {:user_id => users(:quentin).to_param, :id => uploads(:quentin_upload)}
        end
      end

      should_respond_with :redirect
      should_redirect_to 'user_uploads_path(users(:quentin))'
      should_set_the_flash_to(/deleted/i)
    end

  end

end
