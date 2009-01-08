require File.dirname(__FILE__) + '/../test_helper'

class MembershipTest < ActiveSupport::TestCase

  context 'A membership instance' do
    should_belong_to :user
    should_belong_to :group
  end

  should "Create a new membership and set default role" do
    group = Factory(:group, :default_role => 'member')  
    assert_difference 'Membership.count' do
      membership = Factory(:membership, :group => group)
      assert !membership.new_record?, "#{membership.errors.full_messages.to_sentence}"
      membership.reload
      assert membership.role == group.default_role
    end
  end

  should "Create a new 'manager' membership for the creator when a group is created" do

    assert_difference 'Membership.count' do
      group = Factory(:group, :default_role => 'member')
      assert group.memberships.first.role == :manager
    end
  end
  
  def test_associations
    _test_associations
  end

end