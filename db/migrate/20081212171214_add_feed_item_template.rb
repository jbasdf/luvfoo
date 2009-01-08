class AddFeedItemTemplate < ActiveRecord::Migration
  def self.up
    add_column :feed_items, :template, :string
  end

  def self.down
    remove_column :feed_items, :template
  end
end
