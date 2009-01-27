class UpdateEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :attendees_count, :integer, :default => 0, :null => false
  end

  def self.down
    remove_column :events, :attendees_count
  end
end
