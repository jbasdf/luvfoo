class UpdateEvents < ActiveRecord::Migration
  def self.up
    add_column :events, :attendees_count, :integer
  end

  def self.down
    remove_column :events, :attendees_count
  end
end
