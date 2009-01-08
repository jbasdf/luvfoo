require File.dirname(__FILE__) + '/../test_helper'

class EntryTest < ActiveSupport::TestCase

  context 'An entry instance' do
    should_belong_to :user
    should_require_attributes :title, :permalink
    should_have_many :shared_entries
  end

  should "Create a new entry" do
    assert_difference 'Entry.count' do
      entry = Factory(:entry)
      assert !entry.new_record?, "#{entry.errors.full_messages.to_sentence}"
    end
  end

  should "share entry with friends" do
    user = users(:quentin)
    entry = Factory(:entry)
    friend_ids = [users(:aaron).id]
    friend_ids.each do |friend_id|
      shared_entry = entry.share_with_friend(user, friend_id)
      assert !shared_entry.new_record?, "#{shared_entry.errors.full_messages.to_sentence}"
    end

  end

  should "share entry with group" do
    user = users(:africa_member)
    entry = Factory(:entry)
    group_ids = [groups(:africa).id]
    group_ids.each do |group_id|
      shared_entry = entry.share_with_group(user, group_id)
      assert !shared_entry.new_record?, "#{shared_entry.errors.full_messages.to_sentence}"
      assert shared_entry.shared_by_id = user.id
    end    
  end

  def test_associations
    _test_associations
  end

end
