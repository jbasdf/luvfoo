# == Schema Information
# Schema version: 20090123074335
#
# Table name: events
#
#  id              :integer(4)    not null, primary key
#  user_id         :integer(4)    
#  title           :string(255)   
#  start_at        :datetime      
#  end_at          :datetime      
#  summary         :string(255)   
#  location        :string(255)   
#  description     :text          
#  uri             :text          
#  eventable_id    :integer(4)    
#  eventable_type  :string(255)   
#  created_at      :datetime      
#  updated_at      :datetime      
#  attendees_count :integer(4)    
#

class Event < ActiveRecord::Base
  
  acts_as_taggable_on :tags
  
  validates_presence_of :user, :title, :start_at
  
  belongs_to :user
  belongs_to :eventable, :polymorphic => true
  
  has_many :event_users
  has_many :attendees, :source => :user, :through => :event_users, :dependent => :destroy
   
  # named_scopes
  named_scope :recent, :order => 'created_at DESC'

  def after_create
    if eventable.respond_to?(:feed_to)
      feed_item = FeedItem.create(:item => self, :creator_id => self.user_id)
      (eventable.feed_to).each{ |u| u.feed_items << feed_item }
    end
  end
  
end
