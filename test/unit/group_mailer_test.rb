require File.dirname(__FILE__) + '/../test_helper'
require 'group_mailer'

class GroupMailerTest < Test::Unit::TestCase
    
    FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'

    fixtures :users, :groups
    
    include ActionMailer::Quoting

    def setup
        ActionMailer::Base.delivery_method = :test
        ActionMailer::Base.perform_deliveries = true
        ActionMailer::Base.deliveries = []

        @expected = TMail::Mail.new
        @expected.set_content_type "text", "plain", { "charset" => 'utf-8' }
    end

    should "send invite email" do
        user = User.find(users(:quentin))
        group = Group.find(groups(:africa)) 
        email = 'asdf@example.com'
        name = 'asdf'
        subject = "Invitation"
        message = "Come join our group"
        response = GroupMailer.create_invite(user, group, email, name, subject, message)
        assert_match subject, response.subject
        assert_match "#{user.first_name}", response.body  
        assert_equal email, response.to[0]
    end

    private
    def read_fixture(action)
        IO.readlines("#{FIXTURES_PATH}/group_mailer/#{action}")
    end

    def encode(subject)
        quoted_printable(subject, 'utf-8')
    end
end
