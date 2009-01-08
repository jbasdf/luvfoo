require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../integration/integration_helper"


class SpiderTest < ActionController::IntegrationTest

  include Caboose::SpiderIntegrator
  include IntegrationHelper::UserHelper

  #TODO enable spider testing

  # def test_spider_anonymous
  #     puts '********************************'
  #     puts 'spidering site as anonymous user'
  #     get "/"
  #     assert_response 200
  # 
  #     spider(@response.body, '/', { :verbose => true,
  #                                   :ignore_urls => [%r{'.salesforce.com/servlet/servlet.WebToLead.+'}, 
  #                                       %r{^.+signup}, %r{^.+logout}, %r{^.+delete.?}, %r{^.+/destroy.?}], 
  #                                   :ignore_forms => []})
  # end

  # def test_spider_logged_in
  #         puts '********************************'
  #         puts 'spidering site as logged in user'
  #         @user = users(:quentin)
  #         post "/session", :login => @user.login, :password => 'test'
  #         should_set_the_flash_to(/Logged in successfully/i)  
  #         is_redirected_to "users/show"
  #         
  #         assert_response :redirect
  #         assert session[:user]
  #         assert_redirected_to :controller=>'profiles', :action=>'show', :id=>users(:quentin).profile.to_param
  #         follow_redirect!
  # 
  #         spider(@response.body, '/', 
  #         :verbose => true,
  #         :ignore_urls => ['/login', %r{^.+logout}, %r{^.+delete.?}, %r{^.+/destroy.?}], 
  #         :ignore_forms => [])
  #     end
  # 
  #     def test_spider_admin
  #         puts ''
  #         puts 'test_spider_admin'
  #         get "/login"
  #         assert_response :success
  #         post "/login", :user=>{:login => users(:admin).login, :password => 'test'}
  #         assert_response :redirect
  #         assert session[:user]
  #         assert_redirected_to :controller=>'profiles', :action=>'show', :id=>users(:admin).profile.to_param
  #         follow_redirect!
  # 
  #         spider(@response.body, '/', 
  #         :verbose => true,
  #         :ignore_urls => ['/login', %r{^.+logout}, %r{^.+delete.?}, %r{^.+/destroy.?}], 
  #         :ignore_forms => [])
  #     end


end
