require File.dirname(__FILE__) + '/../../test_helper'

class Admin::PagesControllerTest < ActionController::TestCase
  
  VALID_FILE = ActionController::TestUploadedFile.new(File.join(RAILS_ROOT, 'public/images/avatar_default_big.png'), 'image/png')
  
  def setup
    @controller =  Admin::PagesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  should_require_login :edit, :update 

  context "logged in as admin" do
    setup do
      login_as :admin
    end
    
    context "GET edit" do
      setup do
        get :edit
      end
      should_respond_with :success
    end
    
    context "PUT update" do
      setup do
        put :update, :site => {:title => 'title', 
                               :subtitle => 'test for subtitle', 
                               :slogan => 'test for slogan', 
                               :upload => { :uploaded_data => VALID_FILE },
                               :background_color => '444',
                               :content_background_color => 'fff',
                               :top_background_color => '333',
                               :font_color => '000',
                               :font_style => 'Arial',
                               :font_size => '16px',
                               :top_color => '111',
                               :a_font_style => 'Arial',
                               :a_font_color => '222'}
      end
      should_respond_with :success
    end
    
  end

end
