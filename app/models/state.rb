# == Schema Information
# Schema version: 20090123074335
#
# Table name: states
#
#  id           :integer(4)    not null, primary key
#  name         :string(128)   default(""), not null
#  abbreviation :string(3)     default(""), not null
#  country_id   :integer(8)    not null
#

class State < ActiveRecord::Base
    has_many :users
    belongs_to :country
end
