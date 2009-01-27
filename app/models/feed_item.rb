# == Schema Information
# Schema version: 20090123074335
#
# Table name: feed_items
#
#  id               :integer(4)    not null, primary key
#  include_comments :boolean(1)    not null
#  is_public        :boolean(1)    not null
#  item_id          :integer(4)    
#  item_type        :string(255)   
#  created_at       :datetime      
#  updated_at       :datetime      
#  html_cache       :text          
#  creator_id       :integer(4)    
#  template         :string(255)   
#

class FeedItem < ActiveRecord::Base  

  belongs_to :item, :polymorphic => true
  has_many :feeds
  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'
  
  def partial
    template || item.class.name.underscore
  end

end
