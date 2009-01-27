# == Schema Information
# Schema version: 20090123074335
#
# Table name: interests
#
#  id   :integer(4)    not null, primary key
#  name :string(255)   
#

class Interest < ActiveRecord::Base
   has_and_belongs_to_many :users 
end
