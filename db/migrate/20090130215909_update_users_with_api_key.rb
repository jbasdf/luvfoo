class UpdateUsersWithApiKey < ActiveRecord::Migration
  def self.up
    add_column :users, :api_key, :string
    add_index :users, :api_key
  end

  def self.down
    remove_column :users, :api_key
  end
end
