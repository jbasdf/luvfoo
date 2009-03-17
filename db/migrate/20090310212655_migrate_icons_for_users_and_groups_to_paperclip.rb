class MigrateIconsForUsersAndGroupsToPaperclip < ActiveRecord::Migration
  def self.up
    add_column :users, :icon_file_size,    :integer
    add_column :users, :icon_file_name,    :string
    add_column :users, :icon_content_type, :string
    add_column :users, :icon_updated_at,   :datetime
    
    add_column :groups, :icon_file_size,    :integer
    add_column :groups, :icon_file_name,    :string
    add_column :groups, :icon_content_type, :string
    add_column :groups, :icon_updated_at,   :datetime
  end

  def self.down
    remove_column :users, :icon_file_size
    remove_column :users, :icon_file_name
    remove_column :users, :icon_content_type
    remove_column :users, :icon_updated_at
    
    remove_column :groups, :icon_file_size
    remove_column :groups, :icon_file_name
    remove_column :groups, :icon_content_type
    remove_column :groups, :icon_updated_at
  end
end
