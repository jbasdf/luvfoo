require File.dirname(__FILE__) + '/../test_helper'

class PloneTest < ActiveSupport::TestCase

    # this test will send an xml rpc call to whatever server is configured in the
    # testing section of global.config.  Use it to make sure the live integration really is working
    # You will need to enter a real user for the login and password (one on a live site that plone uses to handle authenticatio)
    # def test_plone_integration
    #     login = 'put login here'
    #     password = 'put password here'
    #     user = Factory(:user, :login => login, :password => password)
    #     puts "testing plone integration"
    #     assert Plone.user_to_plone(user, password)
    # end

end