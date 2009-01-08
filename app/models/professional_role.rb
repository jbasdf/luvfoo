# == Schema Information
# Schema version: 20081219083410
#
# Table name: professional_roles
#
#  id         :integer(4)    not null, primary key
#  name       :string(255)   
#  created_at :datetime      
#  updated_at :datetime      
#

class ProfessionalRole < ActiveRecord::Base
    has_many :users
end
