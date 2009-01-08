require 'xmlrpc/client'

class Plone < ActiveRecord::BaseWithoutTable

  def self.user_to_plone(user, password)
    success = true

    begin 

      group_member = PloneGroupRole.find_by_login(user.login) || PloneGroupRole.create(:login => user.login, :rolename => 'Member')
      open_contributor = PloneOpenRole.find_by_login(user.login) || PloneOpenRole.create(:login => user.login, :rolename => 'Contributor')
      open_member = PloneOpenRole.find_by_login(user.login) || PloneOpenRole.create(:login => user.login, :rolename => 'Member')

      server = XMLRPC::Client.new(GlobalConfig.plone_xmlrpc_server, GlobalConfig.plone_xmlrpc_path, GlobalConfig.plone_xmlrpc_port, 
      nil, nil, user.login, password, false, 2000)   

      result = server.call2('xmlrpc_createMemberArea', user.login)

      if result[0] == false
        logger.error "error sending data to plone"
        logger.error result[1].faultString
        success = false
      end

    rescue Exception => e
      logger.error "Error setting up user's plone integration: " + e.message
      success = false
    end

    success
  end

end