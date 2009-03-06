# == Schema Information
# Schema version: 20090123074335
#
# Table name: logos
#
#  id           :integer(4)    not null, primary key
#  site_id      :integer(4)    
#  parent_id    :integer(4)    
#  user_id      :integer(4)    
#  size         :integer(4)    
#  width        :integer(4)    
#  height       :integer(4)    
#  content_type :string(255)   
#  filename     :string(255)   
#  thumbnail    :string(255)   
#  created_at   :datetime      
#  updated_at   :datetime      
#

require 'mime_type_groups'

class Logo < ActiveRecord::Base

  belongs_to :user
  belongs_to :site
  
  has_attached_file :image, :styles => { :original => '870x75' }
  
  validates_attachment_presence :image
  validates_attachment_size :image, :less_than => 5.megabytes
  validates_attachment_content_type :image, :content_type => :image #attachment_options[:content_type]
  
  attr_protected :user_id
  
end
