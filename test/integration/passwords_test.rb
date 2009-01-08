require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../integration/integration_helper"

class PasswordsTest < ActionController::IntegrationTest

  include IntegrationHelper

  def test_anonymous
    bob = new_session
    bob.forgets_password

    quentin = new_session
    quentin.resets_password
  end

  def test_logged_in
    quentin = new_session_as(:quentin)
    quentin.forgets_they_are_logged_in
  end 

  module PasswordActions

    include IntegrationHelper::UserHelper

    def forgets_password
      goes_to("/forgot_password", "passwords/new")
    end

    def resets_password
      goes_to("/reset_password/#{users(:quentin).password_reset_code}", "passwords/edit")
    end

    def forgets_they_are_logged_in
      get "/forgot_password"
      is_redirected_to("users/show")
    end

  end

  def new_session
    open_session do |sess|
      sess.extend(PasswordActions)
      yield sess if block_given?
    end
  end

end
