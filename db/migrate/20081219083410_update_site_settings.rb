class UpdateSiteSettings < ActiveRecord::Migration
  def self.up
    add_column :sites, :link_button_background_color, :string
    add_column :sites, :link_button_font_color, :string
    add_column :sites, :highlight_color, :string
  end

  def self.down
    remove_column :sites, :link_button_background_color
    remove_column :sites, :link_button_font_color
    remove_column :sites, :highlight_color
  end
end
