require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../integration/integration_helper"

class SessionsTest < ActionController::IntegrationTest

  include IntegrationHelper

  def test_session
    quentin = new_session_as(:quentin)
    quentin.logs_out
  end

  module SessionActions

    include IntegrationHelper::UserHelper

  end

  def new_session
    open_session do |sess|
      sess.extend(SessionActions)
      yield sess if block_given?
    end
  end

end
