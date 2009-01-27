# == Schema Information
# Schema version: 20090123074335
#
# Table name: messages
#
#  id          :integer(4)    not null, primary key
#  subject     :string(255)   
#  body        :text          
#  created_at  :datetime      
#  updated_at  :datetime      
#  sender_id   :integer(4)    
#  receiver_id :integer(4)    
#  read        :boolean(1)    not null
#

class Message < ActiveRecord::Base
  
  belongs_to :sender, :class_name => "User"
  belongs_to :receiver, :class_name => "User"
  validates_presence_of :body, :subject, :sender, :receiver

  def after_create
    feed_item = FeedItem.create(:item => self, :creator_id => self.sender_id)
    ([self.sender, self.receiver]).each{ |u| u.feed_items << feed_item }
  end

  def mark_read
    self.read = true
    save!
  end
  
end
