# == Schema Information
# Schema version: 20081219083410
#
# Table name: permissions
#
#  id         :integer(4)    not null, primary key
#  role_id    :integer(4)    not null
#  user_id    :integer(4)    not null
#  created_at :datetime      
#  updated_at :datetime      
#

class Permission < ActiveRecord::Base
    belongs_to :user
    belongs_to :role
end
