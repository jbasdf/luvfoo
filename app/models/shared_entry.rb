# == Schema Information
# Schema version: 20090123074335
#
# Table name: shared_entries
#
#  id               :integer(4)    not null, primary key
#  shared_by_id     :integer(4)    
#  entry_id         :integer(4)    
#  destination_type :string(255)   default(""), not null
#  destination_id   :integer(4)    not null
#  created_at       :datetime      
#  can_edit         :boolean(1)    
#  public           :boolean(1)    
#

class SharedEntry < ActiveRecord::Base
    
    has_many :comments, :as => :commentable, :dependent => :destroy, :order => 'created_at ASC'
    belongs_to :shared_by, :class_name => 'User', :foreign_key => 'shared_by_id'
    belongs_to :entry
    belongs_to :destination, :polymorphic => true

end
