class AddGroupMembersCount < ActiveRecord::Migration
  def self.up
    add_column :groups, :member_count, :integer
    execute "update groups set member_count = (select count(*) from memberships where memberships.group_id = groups.id)"
  end

  def self.down
    remove_column :groups, :member_count
  end
end
