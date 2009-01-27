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
  
  has_attachment :content_type => :image, 
    :storage => :file_system, 
    :max_size => 5.megabytes, 
    :resize_to => '870x75'
  
  validates_as_attachment

  validates_presence_of :size
  validates_presence_of :content_type
  validates_presence_of :filename
  validates_presence_of :user
  validates_inclusion_of :content_type, :in => attachment_options[:content_type], :message => "is not allowed", :allow_nil => true if attachment_options[:content_type]

  attr_protected :user_id
  
end
