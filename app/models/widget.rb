# == Schema Information
# Schema version: 20081219083410
#
# Table name: widgets
#
#  id         :integer(4)    not null, primary key
#  name       :string(255)   
#  created_at :datetime      
#  updated_at :datetime      
#

class Widget < ActiveRecord::Base
    
    # Feeds
    has_many :feeds, :as => :ownable
    has_many :feed_items, :through => :feeds, :order => 'created_at desc'
    
    # news
    has_many :news_items, :as => :newsable, :order => 'created_at desc'
    
end
