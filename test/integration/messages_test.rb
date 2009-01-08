require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../integration/integration_helper"

class MessagesTest < ActionController::IntegrationTest

  include IntegrationHelper

  def test_anonymous
    bob = new_session
    bob.cant_view_inbox
  end

  def test_logged_in
    quentin = new_session_as(:quentin)
    quentin.goes_to_inbox
    quentin.writes_message
    quentin.views_sent_messages
  end 

  module MessageActions

    include IntegrationHelper::UserHelper

    def cant_view_inbox
      get "/users/bob/messages"
      is_redirected_to("sessions/new")
    end

    def goes_to_inbox
      goes_to("/users/#{@user.to_param}/messages", "messages/index")
    end

    def writes_message
      goes_to("/users/#{@user.to_param}/messages/new", "messages/new")
    end

    def views_sent_messages
      goes_to("/messages/sent", "messages/sent")
    end

  end

  def new_session
    open_session do |sess|
      sess.extend(MessageActions)
      yield sess if block_given?
    end
  end

end
