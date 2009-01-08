require File.dirname(__FILE__) + '/../../test_helper'

class Admin::RolesControllerTest < ActiveSupport::TestCase

  fixtures :users, :roles, :permissions

  def setup
    @controller = Admin::RolesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @role = Role.find(:first)
  end

  context "not logged in" do
    should_be_restful do |resource|
      resource.klass      = Role
      resource.object     = :role
      resource.formats    = [:html]
      resource.denied.actions  = [:index, :show, :new, :create, :edit, :update, :destroy]
      resource.denied.flash = /You must be logged in to access this feature/i
      resource.denied.redirect = "login_path"
    end
  end

  context "logged in as user" do
    setup do
      login_as users(:aaron).login
    end
    should_be_restful do |resource|
      resource.klass      = Role
      resource.object     = :role
      resource.formats    = [:html]
      resource.denied.actions  = [:index, :show, :new, :create, :edit, :update, :destroy]
      resource.denied.flash = /You must be logged in to access this feature/i
      resource.denied.redirect = "login_path"
    end
  end

  # TODO add this when we get around to adding an interface to manage roles
  # context "logged in as user" do
  #         setup do
  #             login_as users(:admin).login
  #         end
  #         should_be_restful do |resource|
  #             resource.klass      = Role
  #             resource.object     = :role
  #             resource.formats    = [:html]
  #             resource.actions  = [:index, :show, :new, :create, :edit, :update, :destroy]
  #             resource.create.params = { :rolename => 'testrole' }
  #             resource.update.params = { :rolename => "rolechange" }
  #             resource.create.redirect  = "admin_role_url(@role)"
  #             resource.update.redirect  = "admin_role_url(@role)"
  #             resource.destroy.redirect = "admin_roles_url"
  #         end
  #     end

end