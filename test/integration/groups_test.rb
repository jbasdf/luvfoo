require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../integration/integration_helper"

class GroupsTest < ActionController::IntegrationTest

  include IntegrationHelper

  def test_view_group_as_non_member
    new_session_as(:aaron) do |aaron| 
      aaron.views_group_home
    end
  end

  def test_view_group_as_group_creator
    new_session_as(:quentin) do |quentin| 
      quentin.views_group_home
    end
  end

  def test_view_group_as_admin
    new_session_as(:admin) do |admin| 
      admin.views_group_home
    end
  end

  def test_view_group_as_member
    new_session_as(:africa_member) do |africa_member| 
      africa_member.views_group_home
    end
  end

  module GroupActions

    include IntegrationHelper::UserHelper

    def views_group_home
      goes_to("/groups/#{groups(:africa).to_param}", "groups/show")
    end

  end

  def new_session
    open_session do |sess|
      sess.extend(GroupActions)
      yield sess if block_given?
    end
  end

end