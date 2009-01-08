require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../integration/integration_helper"

class PhotosTest < ActionController::IntegrationTest

  include IntegrationHelper

  def test_anonymous
    bob = new_session
    bob.views_quentins_photos
  end

  module PhotoActions

    include IntegrationHelper::UserHelper

    def views_quentins_photos
      goes_to("/users/#{users(:quentin).to_param}/photos", "users/photos/index")
    end

  end

  def new_session
    open_session do |sess|
      sess.extend(PhotoActions)
      yield sess if block_given?
    end
  end

end
