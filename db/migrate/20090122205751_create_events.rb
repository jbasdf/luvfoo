class CreateEvents < ActiveRecord::Migration
  def self.up
    create_table :events do |t|
      t.integer :user_id
      t.string :title
      t.datetime :start_at
      t.datetime :end_at
      t.string :summary
      t.string :location
      t.text :description
      t.text :uri
      t.integer :eventable_id
      t.string :eventable_type
      t.timestamps
    end
  end

  def self.down
    drop_table :events
  end
end