# == Schema Information
# Schema version: 20090123074335
#
# Table name: feeds
#
#  id           :integer(4)    not null, primary key
#  ownable_id   :integer(4)    
#  feed_item_id :integer(4)    
#  ownable_type :string(255)   
#

class Feed < ActiveRecord::Base
  belongs_to :feed_item
  belongs_to :ownable, :polymorphic => true
end
