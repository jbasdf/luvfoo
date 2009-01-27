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
  
  named_scope :current_events_for, lambda { |*args| { :include => [:event],
                                                      :conditions => ["events.start_at > Now() AND event_users.user_id = ?", (args.first.id)]} }
end
