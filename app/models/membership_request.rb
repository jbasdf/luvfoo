# == Schema Information
# Schema version: 20090123074335
#
# Table name: membership_requests
#
#  id         :integer(4)    not null, primary key
#  group_id   :integer(4)    
#  user_id    :integer(4)    
#  created_at :datetime      
#  updated_at :datetime      
#

class MembershipRequest < ActiveRecord::Base
  belongs_to :user
  belongs_to :group
  
  def decline(decliner)
    return false if !group.can_edit?(decliner)
    destroy
    return true
  end
  
end
