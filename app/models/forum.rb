# == Schema Information
# Schema version: 20090123074335
#
# Table name: forums
#
#  id               :integer(4)    not null, primary key
#  name             :string(255)   
#  description      :text          
#  position         :integer(4)    
#  created_at       :datetime      
#  updated_at       :datetime      
#  forumable_type   :string(255)   
#  forumable_id     :integer(4)    
#  url_key          :string(255)   
#  description_html :text          
#  topics_count     :integer(4)    default(0)
#  posts_count      :integer(4)    default(0)
#

# == Schema Information
# Schema version: 20081219083410
#
# Table name: forums
#
#  id               :integer(4)    not null, primary key
#  name             :string(255)   
#  description      :text          
#  position         :integer(4)    
#  created_at       :datetime      
#  updated_at       :datetime      
#  forumable_type   :string(255)   
#  forumable_id     :integer(4)    
#  url_key          :string(255)   
#  description_html :text          
#  topics_count     :integer(4)    default(0)
#  posts_count      :integer(4)    default(0)
#
class Forum < ActiveRecord::Base
  
  belongs_to :forumable, :polymorphic => true
  
  has_permalink :name, :url_key, :scope => :forumable_id
  
  acts_as_list

  validates_presence_of :name

  has_many :moderatorships, :dependent => :delete_all
  has_many :moderators, :through => :moderatorships, :source => :user

  has_many :topics, :order => 'sticky desc, replied_at desc', :dependent => :delete_all
  has_one  :recent_topic, :class_name => 'Topic', :order => 'sticky desc, replied_at desc'

  # this is used to see if a forum is "fresh"... we can't use topics because it puts
  # stickies first even if they are not the most recently modified
  has_many :recent_topics, :class_name => 'Topic', :order => 'replied_at DESC'
  has_one  :recent_topic,  :class_name => 'Topic', :order => 'replied_at DESC'

  has_many :posts,     :order => "#{Post.table_name}.created_at DESC", :dependent => :delete_all
  has_one  :recent_post, :order => "#{Post.table_name}.created_at DESC", :class_name => 'Post'

  format_attribute :description
  
  named_scope :by_newest, :order => "created_at DESC"
  named_scope :recent, lambda { { :conditions => ['created_at > ?', 1.week.ago] } }
  named_scope :by_position, :order => "position ASC"
  named_scope :site_forums, :conditions => ["forumable_type='Site'"] 
  
  def to_param
    url_key
  end
  
end
