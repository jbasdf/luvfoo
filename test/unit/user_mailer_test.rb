require File.dirname(__FILE__) + '/../test_helper'
require 'user_mailer'

class UserMailerTest < Test::Unit::TestCase
    
    fixtures :users
    
    FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'

    include ActionMailer::Quoting

    def setup
        ActionMailer::Base.delivery_method = :test
        ActionMailer::Base.perform_deliveries = true
        ActionMailer::Base.deliveries = []

        @expected = TMail::Mail.new
        @expected.set_content_type "text", "plain", { "charset" => 'utf-8' }
    end

    should "send signup notification email" do
        user = User.find(users(:quentin))
        response = UserMailer.create_signup_notification(user)   
        assert_match "Activate your #{GlobalConfig.application_name} account!", response.subject
        assert_match "#{user.login}", response.body
        assert_match "http://#{GlobalConfig.application_url}/activate/#{user.activation_code}", response.body    
        assert_equal user.email, response.to[0]
    end

    should "send signup activation email" do
        user = User.find(users(:quentin))
        response = UserMailer.create_activation(user) 
        assert_match "Your #{GlobalConfig.application_name} account has been activated!", response.subject
        assert_equal user.email, response.to[0]
    end

    should "send forgot password email" do
        user = User.find(users(:quentin))
        response = UserMailer.create_forgot_password(user)   
        assert_match "You have requested to change your #{GlobalConfig.application_name} password", response.subject
        assert_equal user.email, response.to[0]
    end
    
    should "send password reset email" do
        user = User.find(users(:quentin))
        response = UserMailer.create_reset_password(user)
        assert_match "Your #{GlobalConfig.application_name} password has been reset", response.subject     
        assert_match /password has been reset/, response.body           
        assert_equal user.email, response.to[0]
    end
    
    should "send invite email" do
        user = User.find(users(:quentin)) 
        email = 'asdf@example.com'
        name = 'asdf'
        subject = "Invitation"
        message = "Come join our group"
        response = UserMailer.create_invite(user, email, name, subject, message)
        assert_match subject, response.subject
        assert_match "#{user.first_name}", response.body  
        assert_equal email, response.to[0]
    end
    
    private
    def read_fixture(action)
        IO.readlines("#{FIXTURES_PATH}/user_mailer/#{action}")
    end

    def encode(subject)
        quoted_printable(subject, 'utf-8')
    end
end
