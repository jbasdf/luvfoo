require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../integration/integration_helper"

class PageTest < ActionController::IntegrationTest

  include IntegrationHelper

  def test_anonymous
    bob = new_session
    bob.views_getting_started
    bob.views_default
  end

  def test_logged_in
    quentin = new_session_as(:quentin)
    quentin.views_get_bookmarklet
  end 

  module PageActions

    include IntegrationHelper::UserHelper

    # note both page and content work
    
    def views_getting_started
      goes_to("/content/getting_started", nil)
    end

    def views_default
      goes_to("/page/default", nil)
    end

    def views_get_bookmarklet
      goes_to("/protected/get_bookmarklet", nil)
    end

  end

  def new_session
    open_session do |sess|
      sess.extend(PageActions)
      yield sess if block_given?
    end
  end

end
