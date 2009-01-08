require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../integration/integration_helper"

class UsersTest < ActionController::IntegrationTest

  include IntegrationHelper

  def test_user_functionality
    quentin = new_session_as(:quentin)
    aaron = new_session_as(:aaron)
    quentin.views_dashboard
    aaron.views_dashboard
    quentin.edits_profile
    aaron.edits_quentins_profile
    aaron.edits_profile
    quentin.logs_out
  end 

  def test_signup_new_user
    new_session do |bob|
      bob.goes_to_login
      bob.signs_up
      bob.signup :login => 'bob', 
      :email => 'bob@example.com',
      :password => 'asdf1234', 
      :password_confirmation => 'asdf1234', 
      :language_id => languages(:english).id, 
      :language_ids => [languages(:english).id, languages(:japanese).id, languages(:tonga).id],
      :country_id => countries(:usa).id,
      :first_name => 'Bob',
      :last_name => 'Decker',
      :grade_level_experience_ids => [grade_level_experiences(:college).id, grade_level_experiences(:first).id, grade_level_experiences(:high_school).id],
      :terms_of_service => true            
    end
  end

  module UserActions

    include IntegrationHelper::UserHelper

    def views_dashboard
      goes_to("/users/#{@user.to_param}", "users/show")
    end

    def edits_profile
      goes_to("/users/#{@user.to_param}/edit", "users/edit")
    end

    def edits_quentins_profile
      get "/users/#{users(:quentin).to_param}/edit"
      is_redirected_to("users/show")
    end

    def signs_up
      goes_to("/signup", "users/new")
    end

    def signup(options)
      post "/users", :user => options
      should_set_the_flash_to(/Thanks for signing up/i) 
      is_redirected_to "users/welcome"
    end

  end

  def new_session
    open_session do |sess|
      sess.extend(UserActions)
      yield sess if block_given?
    end
  end

end
