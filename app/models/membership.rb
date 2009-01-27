# == Schema Information
# Schema version: 20090123074335
#
# Table name: memberships
#
#  id         :integer(4)    not null, primary key
#  group_id   :integer(4)    
#  user_id    :integer(4)    
#  banned     :boolean(1)    
#  role       :string(255)   default("--- :member\n")
#  created_at :datetime      
#  updated_at :datetime      
#


class Membership < ActiveRecord::Base
  belongs_to :user
  belongs_to :group

  def after_create
    feed_to = group.feed_to
    feed_to = (feed_to | user.feed_to) if group.visibility > Group::INVISIBLE
    feed_item = FeedItem.create(:item => self, :creator_id => self.user_id)
    feed_to.each{ |u| u.feed_items << feed_item }
  end

  def after_destroy
    feed_item = FeedItem.create(:item => group, :template => 'left_group', :creator_id => user_id)
    (group.feed_to).each{ |u| u.feed_items << feed_item }
  end
  
  # roles can be defined as symbols.  We want to store them as strings in the database
  def role= val
    write_attribute(:role, val.to_s)
  end

  def role
    read_attribute(:role).to_sym
  end

end
