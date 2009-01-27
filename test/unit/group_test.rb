require File.dirname(__FILE__) + '/../test_helper'

class GroupTest < ActiveSupport::TestCase

  context 'A group instance' do

    setup do
      @group = groups(:africa)
      @user = users(:quentin)
    end

    should_belong_to :creator
    should_have_many :comments
    should_have_many :events
    should_have_many :pages
    should_have_many :membership_requests        
    # TODO the next version of shoulda should handle the :source param.  Uncomment these lines when it does
    #should_have_many :photos, :class_name => 'GroupPhoto'
    #should_have_many :members, :through => :memberships, :source => :user
    should_have_many :shared_uploads
    should_have_many :uploads

    should_require_attributes :description
    should_require_attributes :creator
    
    should_require_unique_attributes :name

    context "quentin" do
      should "be able to edit" do
        assert @group.can_edit?(users(:quentin))
      end
    end

    context "aaron" do
      should "not be able to edit" do
        assert !@group.can_edit?(users(:aaron))
      end
    end

  end

  context "public group" do
    should "be visible to invalid user" do
      group = Factory(:group)
      user = :false
      assert group.is_content_visible?(user)
    end
  
    should "be visible to nil user" do
      group = Factory(:group)
      user = nil
      assert group.is_content_visible?(user)
    end
  
    should "be visible to valid user" do
      group = Factory(:group)
      assert group.is_content_visible?(@user)
    end
  end
  
  context 'invisible group' do
  
    should "be invisible but visible to the right user" do
      group = groups(:invisible)
      user = users(:invisible_member)
      assert group.is_content_visible?(user)
    end

    should "not be visible to nil user" do
      group = groups(:invisible)
      user = nil
      assert !group.is_content_visible?(user)
    end
      
    should "not be visible to invalid user" do
      group = groups(:invisible)
      user = :false
      assert !group.is_content_visible?(user)
    end
    
  end
  
  should "Create a new group" do
    assert_difference 'Group.count' do
      group = Factory(:group)
      assert !group.new_record?, "#{group.errors.full_messages.to_sentence}"
      assert group.current_state == :approved
    end
  end

  should "add a 'manager' role for the group creator" do
    assert_difference 'Group.count' do
      group = Factory(:group)
      assert group.members.in_role(:manager).include?(group.creator)
    end
  end
  
  should "Create a new group and set default role" do
    assert_difference 'Group.count' do
      group = Factory(:group, :default_role => 'dude')
      assert !group.new_record?, "#{group.errors.full_messages.to_sentence}"
      assert group.current_state == :approved
      assert group.default_role == :dude
    end
  end

  should "get members in the 'member' role" do
    group = groups(:africa)
    members = group.members.in_role(:member, :limit => 10)
    assert members.length > 0
  end

  should "get members in the 'manager' role" do
    group = groups(:africa)
    members = group.members.in_role(:manager, :limit => 10)
    assert members.length > 0
  end

  should "get a list of other users to share activity feed with" do
    share_with = groups(:africa).feed_to
    assert share_with.include?(users(:quentin))
    assert share_with.include?(users(:africa_member))
  end
  
  should "be taggable" do
    group = Factory(:group)
    assert !group.new_record?, "#{group.errors.full_messages.to_sentence}"
    group.tag_list = "country, ngo, Africa"
    assert group.save!
    assert Group.tagged_with("country", :on => :tags).include?(group)
  end

  should "ban a group" do
    group = Factory(:group)
    group.ban!
    assert group.banned?
  end

  should "delete a group" do
    group = Factory(:group)
    group.delete!
    group.reload
    assert group.visibility == Group::DELETED
  end

end
