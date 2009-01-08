class CreateStatusUpdates < ActiveRecord::Migration
  def self.up
    create_table :status_updates do |t|
      t.integer :user_id
      t.string :text
      t.timestamps
    end
  end

  def self.down
    drop_table :status_updates
  end
end
