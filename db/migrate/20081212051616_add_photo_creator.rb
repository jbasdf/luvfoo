class AddPhotoCreator < ActiveRecord::Migration
  def self.up
    add_column :photos, :creator_id, :integer
  end

  def self.down
    remove_column :photos, :creator_id
  end
end
