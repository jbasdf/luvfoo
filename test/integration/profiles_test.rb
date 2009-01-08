require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../integration/integration_helper"

class ProfilesTest < ActionController::IntegrationTest

  include IntegrationHelper

  def test_view_profiles
    quentin = new_session_as(:quentin)
    quentin.view_all_profiles
    quentin.view_user_profile(users(:aaron))
    quentin.logs_out

    bob = new_session
    bob.view_all_profiles
    bob.view_user_profile(:quentin)
  end

  module ProfileActions

    include IntegrationHelper::UserHelper

    def view_all_profiles
      goes_to("/profiles", "profiles/index")
    end

    def view_user_profile(user)
      goes_to("/profiles/#{user.to_param}", "profiles/show")
    end

  end

  def new_session
    open_session do |sess|
      sess.extend(ProfileActions)
      yield sess if block_given?
    end
  end

end
