# == Schema Information
# Schema version: 20090123074335
#
# Table name: groups
#
#  id                        :integer(4)    not null, primary key
#  creator_id                :integer(4)    
#  name                      :string(255)   
#  description               :text          
#  icon                      :string(255)   
#  state                     :string(255)   
#  url_key                   :string(255)   
#  created_at                :datetime      
#  updated_at                :datetime      
#  default_role              :string(255)   default("member")
#  visibility                :integer(4)    default(2)
#  requires_approval_to_join :boolean(1)    
#

class Group < ActiveRecord::Base

  include SecureMethods

  DELETED = -1
  INVISIBLE = 0
  PRIVATE = 1
  PUBLIC = 2

  acts_as_taggable_on :tags
  acts_as_state_machine :initial => :approved

  validates_presence_of :creator

  # give the group a permalink
  has_permalink :name, :url_key

  # events
  has_many :events, :as => :eventable, :order => 'created_at desc'
  
  # Feeds
  has_many :feeds, :as => :ownable
  has_many :feed_items, :through => :feeds, :order => 'created_at desc'

  # news
  has_many :news_items, :as => :newsable, :order => 'created_at desc'

  # forum
  has_many :forums, :as => :forumable, :order => 'created_at asc'

  # comments
  has_many :comments, :as => :commentable, :order => 'created_at desc'

  # photos
  has_many :photos, :as => :photoable, :order => 'created_at desc'

  # shared entries
  has_many :shared_entries, :as => :destination, :order => 'created_at desc', :include => :entry
  has_many :public_google_docs, :through => :shared_entries, :source => 'entry', :conditions => 'google_doc = true AND public = true', :select => "*"

  # shared uploads
  has_many :shared_uploads, :as => :shared_uploadable, :order => 'created_at desc', :include => :upload
  has_many :uploads, :as => :uploadable, :order => 'created_at desc'

  # pages
  has_many :pages, :as => :contentable, :class_name => 'ContentPage', :order => 'created_at desc'

  # membership and users
  has_many :membership_requests
  has_many :pledges, :through => :membership_requests, 
                    :dependent => :destroy, 
                    :source => :user

  belongs_to :creator, :class_name => 'User', :foreign_key => 'creator_id'   

  has_many :memberships, :dependent => :destroy
  has_many :members, :through => :memberships, 
                    :dependent => :destroy,
                    :order => 'last_name, first_name',
                    :conditions => 'banned != true',
                    :select => 'users.*, memberships.role',
                    :source => :user do
                      def in_role(role, options = {})
                        find :all, { :conditions => ['role = ?' , role.to_s] }.merge(options)
                      end
                    end

  acts_as_solr :fields => [ :content_p, :content_us, :content_a, :visibility ]

  after_create {|group| group.memberships.create(:role => :manager, :user_id => group.creator_id)}
  after_create :create_forum
  after_create :create_feed_item
  after_update {|group| group.create_feed_item 'updated_group'}

  def create_feed_item template = nil
    feed_item = FeedItem.create(:item => self, :creator_id => self.creator_id, :template => template)
    (self.creator.feed_to).each{ |u| u.feed_items << feed_item }
  end
  
  def create_forum
    @forum = self.forums.build(:name => self.name,
      :description => _("Forum For %{forum}") % {:forum => self.name})
    @forum.save
  end
  
  def feed_to
    [self] + self.members
  end

  def content_p
    visibility > INVISIBLE ? "#{name} #{description} #{tags.collect{|t| t.name}.join(' ')}" : ''
  end

  def content_u
    content_p
  end

  def content_a
    "#{name} #{description} #{tags.collect{|t| t.name}.join(' ')}"
  end

  def default_role= val
    write_attribute(:default_role, val.to_s)
  end

  def default_role
    read_attribute(:default_role).to_sym
  end

  def is_content_visible? user
    return true if self.visibility > Group::PRIVATE 
    return false if user == :false || user.nil?
    user.is_admin? || self.is_member?(user)
  end

  #Named scopes
  named_scope :visible, :order => "name ASC", :conditions => ["visibility > 0"]

  # state information                   
  state :approved, :after => :notify_approve 
  state :banned, :after => :notify_ban

  event :approve do 
    transitions :to => :approved, :from => :banned  
  end

  event :ban do 
    transitions :to => :banned, :from => :approved 
  end

  # icon
  file_column :icon, :magick => {
    :versions => { 
      :bigger => {:crop => "1:1", :size => "200x200", :name => "bigger"},
      :big => {:crop => "1:1", :size => "150x150", :name => "big"},
      :medium => {:crop => "1:1", :size => "100x100", :name => "medium"},
      :small => {:crop => "1:1", :size => "50x50", :name => "small"}
    }
  }

  # validations
  validates_presence_of :name, :description
  validates_uniqueness_of :name

  def to_param
    url_key
  end

  def notify_approve
  end

  def notify_ban
  end

  def is_member?(user)
    return false if user.nil?
    members.include?(user)
  end

  def is_pending_member?(user)
    return false if user.nil?
    pledges.include?(user)
  end

  def can_edit?(user)
    return false if user.nil?
    check_creator(user) || members.in_role(:manager).include?(user)
  end

  def can_participate?(user)
    return false if user == :false
    user.has_role?('administrator') || !members.find(:all, :conditions => "user_id = #{user.id} AND role != 'banned' AND role != 'observer'").empty?
  end

  def remove_member(user)
    membership = memberships.find_by_user_id(user.id)
    membership.destroy
  end

  def remove_pledge(user)
    pledge = membership_requests.find_by_user_id(user.id)
    pledge.destroy
  end

  # actually deleting a group could cause some problems so 
  # we cheat and just say we delete it
  def delete!
    update_attributes(:visibility => DELETED)
  end

end
