# == Schema Information
# Schema version: 20090123074335
#
# Table name: status_updates
#
#  id         :integer(4)    not null, primary key
#  user_id    :integer(4)    
#  text       :string(255)   
#  created_at :datetime      
#  updated_at :datetime      
#

class StatusUpdate < ActiveRecord::Base
  
  validates_presence_of :user
  
  belongs_to :user
  
  has_many :comments, :as => :commentable, :dependent => :destroy, :order => 'created_at DESC'  
  has_many :feed_items, :as => :item, :order => 'created_at desc', :dependent => :destroy    
  
  named_scope :recent, :order => 'created_at DESC'
  
  def after_create
    feed_item = FeedItem.create(:item => self, :creator_id => self.user_id)
    (self.user.feed_to).each{ |u| u.feed_items << feed_item }
  end
  
  def can_edit?(user)
    user.id == self.user_id || user.is_admin?
  end
  
end
