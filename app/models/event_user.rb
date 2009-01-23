class EventUser < ActiveRecord::Base
  belongs_to :user
  belongs_to :event, :counter_cache => 'attendees_count'
end