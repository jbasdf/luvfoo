class AddAttachmentsImageToLogo < ActiveRecord::Migration
  
  def self.up
    #migrate database
    rename_column :logos, :filename, :image_file_name
    rename_column :logos, :content_type, :image_content_type
    rename_column :logos, :size, :image_file_size
    add_column :logos, :image_updated_at, :datetime

    remove_column :logos, :width
    remove_column :logos, :height
    remove_column :logos, :parent_id
    remove_column :logos, :thumbnail

    #prevent errors caused by caching non-migrated data
    Logo.reset_column_information

    #migrate files
  end

  def self.down
    # There is no going back
  end
end
