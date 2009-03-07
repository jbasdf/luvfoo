class AddSiteThemes < ActiveRecord::Migration
  def self.up
    add_column :sites, :theme, :string, :default => 'default', :null => false
  end

  def self.down
    remove_column :sites, :theme
  end
end