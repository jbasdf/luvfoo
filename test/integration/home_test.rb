require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../integration/integration_helper"

class HomeTest < ActionController::IntegrationTest

  include IntegrationHelper

  def test_anonymous
    bob = new_session
    bob.goes_home
    bob.contacts
  end

  def test_logged_in
    quentin = new_session_as(:quentin)
    quentin.goes_home
    quentin.contacts
  end 

  module GeneralActions

    include IntegrationHelper::UserHelper

    def goes_home
      goes_to("/home", "home/home")
    end

    def contacts
      goes_to("/contact", "home/contact")
    end

  end

  def new_session
    open_session do |sess|
      sess.extend(GeneralActions)
      yield sess if block_given?
    end
  end

end
