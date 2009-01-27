# == Schema Information
# Schema version: 20090123074335
#
# Table name: plone_open_roles
#
#  id         :integer(4)    not null, primary key
#  login      :string(255)   
#  rolename   :string(255)   
#  created_at :datetime      
#  updated_at :datetime      
#

class PloneOpenRole < ActiveRecord::Base
end
