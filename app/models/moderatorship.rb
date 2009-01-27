# == Schema Information
# Schema version: 20090123074335
#
# Table name: moderatorships
#
#  id       :integer(4)    not null, primary key
#  forum_id :integer(4)    
#  user_id  :integer(4)    
#

class Moderatorship < ActiveRecord::Base
  belongs_to :forum
  belongs_to :user
  before_create { |r| count(:id, :conditions => ['forum_id = ? and user_id = ?', r.forum_id, r.user_id]).zero? }
	  
end
