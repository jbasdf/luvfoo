class CreateEventUsers < ActiveRecord::Migration
  def self.up
    create_table :event_users do |t|
      t.integer :user_id
      t.integer :event_id
      t.timestamps
    end
    
    add_index :event_users, [:user_id]
    add_index :event_users, [:event_id]
    
  end

  def self.down
    drop_table :event_users
  end
end
