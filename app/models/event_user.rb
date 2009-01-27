# == Schema Information
# Schema version: 20090123074335
#
# Table name: event_users
#
#  id         :integer(4)    not null, primary key
#  user_id    :integer(4)    
#  event_id   :integer(4)    
#  created_at :datetime      
#  updated_at :datetime      
#

class EventUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :event, :counter_cache => 'attendees_count'
end
