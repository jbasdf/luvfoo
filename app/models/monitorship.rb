# == Schema Information
# Schema version: 20090123074335
#
# Table name: monitorships
#
#  id       :integer(4)    not null, primary key
#  topic_id :integer(4)    
#  user_id  :integer(4)    
#  active   :boolean(1)    default(TRUE)
#

class Monitorship < ActiveRecord::Base
  belongs_to :user
  belongs_to :topic
	
end
