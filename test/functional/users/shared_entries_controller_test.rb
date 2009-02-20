require File.dirname(__FILE__) + '/../../test_helper'

class Users::SharedEntriesControllerTest < Test::Unit::TestCase


  def setup
    @controller = Users::SharedEntriesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @entry = entries(:quentin_entry)
  end

  should_require_login :index, :create, :destroy
  
  context 'not logged in' do

    context "GET index" do
      setup do
        get :index, { :user_id => users(:quentin).to_param }
      end

      should_respond_with :redirect
      should_redirect_to 'login_path'
      should_set_the_flash_to NOT_LOGGED_IN_MSG
    end

    context 'on POST to :create while logged not in' do
      setup do
        assert_no_difference "SharedEntry.count" do
          post :create, { :user_id => users(:quentin).to_param }
        end
      end

      should_respond_with :redirect
      should_redirect_to 'login_path'
      should_set_the_flash_to NOT_LOGGED_IN_MSG
    end

    context 'on DELETE to :destroy' do
      setup do
        assert_no_difference "SharedEntry.count" do
          delete :destroy, { :user_id => users(:quentin).to_param }
        end
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

    context "GET show" do
      setup do
        get :show, { :user_id => users(:aaron).to_param, :id => shared_entries(:shared_with_aaron) }
      end

      should_redirect_to "shared_entries(:shared_with_aaron).entry.permalink"
    end

    context "GET new" do
      setup do
        get :new, { :u => 'http://www.luvfoo.com', :c => 'Niche social networking', :t => 'Luvfoo, software for niche social networking' }
      end

      should_respond_with :success
      should_render_template 'new'
    end

    # context 'on POST to :create aaron sharing with quentin' do
    #   setup do
    #     assert_difference "SharedEntry.count", 1 do
    #       post :create, { :entry => {:permalink => 'http://www.theplancollection.com', :title => 'House Plans', :body => 'A website with house plans'}, 
    #       :friend_ids => [users(:quentin).id], :group_ids => [groups(:africa).id], :share_to_edit => 'on', :profile => 'on' }
    #     end
    #   end
    # 
    #   should_set_the_flash_to(/Web page was shared/i)
    #   should_respond_with :redirect
    #   should_redirect_to 'user_path(@user)'
    # end

    # TODO test destroy when it is done
    # context 'on DELETE to :destroy' do
    #       setup do
    #         assert_difference "SharedEntry.count", -1 do
    #           delete :destroy, {:id => shared_entries(:shared_with_aaron).id}
    #         end
    #       end
    # 
    #       should_respond_with :redirect
    #       should_redirect_to 'user_path(users(:aaron))'
    #       should_set_the_flash_to(/Deleted shared entry/i)
    #     end

  end

end