require File.dirname(__FILE__) + '/../test_helper'

class RoleTest < ActiveSupport::TestCase

    should_require_attributes :rolename
    should_have_many :permissions
    
    context "Create new role" do
        should "should create a new role" do
            assert_difference 'Role.count' do
                new_role = Role.create(:rolename => "new role")
                new_role.save
            end
        end
    end

    should "test associations" do
        _test_associations
    end
    
end





