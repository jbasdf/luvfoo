# == Schema Information
# Schema version: 20090123074335
#
# Table name: shared_pages
#
#  id              :integer(4)    not null, primary key
#  content_page_id :integer(4)    
#  share_type      :string(255)   default(""), not null
#  share_id        :integer(4)    not null
#  status          :integer(4)    default(0)
#  created_at      :datetime      
#  updated_at      :datetime      
#

class SharedPages < ActiveRecord::Base
end
