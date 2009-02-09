# == Schema Information
# Schema version: 20090123074335
#
# Table name: users
#
#  id                        :integer(4)    not null, primary key
#  login                     :string(255)   
#  email                     :string(255)   
#  crypted_password          :string(40)    
#  salt                      :string(40)    
#  remember_token            :string(255)   
#  remember_token_expires_at :datetime      
#  activation_code           :string(40)    
#  activated_at              :datetime      
#  password_reset_code       :string(40)    
#  enabled                   :boolean(1)    default(TRUE)
#  terms_of_service          :boolean(1)    not null
#  can_send_messages         :boolean(1)    default(TRUE)
#  time_zone                 :string(255)   default("UTC")
#  first_name                :string(255)   
#  last_name                 :string(255)   
#  website                   :string(255)   
#  blog                      :string(255)   
#  flickr                    :string(255)   
#  about_me                  :text          
#  aim_name                  :string(255)   
#  gtalk_name                :string(255)   
#  ichat_name                :string(255)   
#  icon                      :string(255)   
#  location                  :string(255)   
#  created_at                :datetime      
#  updated_at                :datetime      
#  is_active                 :boolean(1)    
#  youtube_username          :string(255)   
#  flickr_username           :string(255)   
#  identity_url              :string(255)   
#  city                      :string(255)   
#  state_id                  :integer(4)    
#  zip                       :string(255)   
#  country_id                :integer(4)    
#  phone                     :string(255)   
#  phone2                    :string(255)   
#  msn                       :string(255)   
#  skype                     :string(255)   
#  yahoo                     :string(255)   
#  organization              :string(255)   
#  grade_experience          :integer(4)    
#  language_id               :integer(4)    
#  why_joined                :text          
#  skills                    :text          
#  occupation                :text          
#  plone_password            :string(40)    
#  tmp_password              :string(40)    
#  professional_role_id      :integer(4)    
#  blog_rss                  :string(255)   
#  protected_profile         :text          
#  public_profile            :text          
#  posts_count               :integer(4)    default(0)
#  last_seen_at              :datetime      
#

require 'digest/sha1'
require 'mime/types'
require 'mime_type_groups'

class User < ActiveRecord::Base

  include UrlMethods
  include RssMethods
  include DatabaseMethods
  include SalesforceMethods
  include PropertyBagMethods
  
  acts_as_tagger

  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessor :password
  attr_protected :crypted_password, :salt, :remember_token, :remember_token_expires_at, :activation_code, :activated_at,
                 :password_reset_code, :enabled, :can_send_messages, :is_active, :created_at, :updated_at, :plone_password,
                 :posts_count

  validates_presence_of     :password,                   :if => :password_required?
  validates_presence_of     :password_confirmation,      :if => :password_required? && Proc.new { |u| !u.password.blank? }
  validates_length_of       :password, :within => 4..40, :if => :password_required? && Proc.new { |u| !u.password.blank? }
  validates_confirmation_of :password,                   :if => :password_required? && Proc.new { |u| !u.password.blank? }

  validates_presence_of     :login, :email, :first_name, :last_name
  validates_uniqueness_of   :login, :email, :case_sensitive => false

  validates_length_of       :login, :within => 3..40, :if => Proc.new { |u| !u.login.blank? }    
  validates_format_of       :login, :with => /^[a-z0-9-]+$/i, :message => 'may only contain letters, numbers or a hyphen.'

  validates_length_of       :email, :within => 6..100,:if => Proc.new { |u| !u.email.blank? }
  validates_format_of       :email, :with => /(^([^@\s]+)@((?:[-_a-z0-9]+\.)+[a-z]{2,})$)|(^$)/i, :message => 'does not look like a valid email address.'

  #validates_acceptance_of :terms_of_service, :allow_nil => false, :accept => true
  #validates_acceptance_of :terms_of_service, :on => :create

  composed_of :tz, :class_name => 'TZInfo::Timezone', :mapping => %w( time_zone time_zone )

  has_many :permissions, :dependent => :destroy
  has_many :roles, :through => :permissions

  # Feeds
  has_many :feeds, :as => :ownable, :dependent => :destroy
  has_many :feed_items, :through => :feeds, :order => 'created_at desc', :dependent => :destroy
  has_many :private_feed_items, :through => :feeds, :source => :feed_item, :conditions => {:is_public => false}, :order => 'created_at desc'
  has_many :public_feed_items, :through => :feeds, :source => :feed_item, :conditions => {:is_public => true}, :order => 'created_at desc'
  #has_many :my_feed_items, :through => :feeds, :source => :feed_item, :conditions => ["feed_item.creator_id=?", self.id], :order => 'created_at desc'
  
  def my_feed_items limit = 20
    FeedItem.find(:all, :joins => 'INNER JOIN feeds ON feeds.feed_item_id = feed_items.id', :conditions => ["feeds.ownable_type='User' AND feeds.ownable_id=? AND feed_items.creator_id=?",self.id,self.id], :order => 'created_at desc', :limit => limit)
  end

  # Events
  has_many :events, :dependent => :destroy
  has_many :event_users, :dependent => :destroy
  has_many :attending_events, :source => :event, :through => :event_users, :dependent => :destroy
  
  # Messages
  has_many :sent_messages,     :class_name => 'Message', :order => 'created_at desc', :foreign_key => 'sender_id', :dependent => :destroy
  has_many :received_messages, :class_name => 'Message', :order => 'created_at desc', :foreign_key => 'receiver_id', :dependent => :destroy
  has_many :unread_messages,   :class_name => 'Message', :foreign_key => 'receiver_id', :conditions => ["`read`=?",false] 

  # Groups
  has_many :memberships, :dependent => :destroy
  has_many :groups, :through => :memberships, :conditions => 'role != \'banned\''
  has_many :public_groups, :through => :memberships, :source => :group, :foreign_key => 'group_id', :conditions => 'groups.visibility > 0'
  has_many :created_groups, :class_name => 'Group', :foreign_key => 'creator_id'

  # Friends
  has_many :friendships, :class_name  => "Friend", :foreign_key => 'inviter_id', :conditions => "status = #{Friend::ACCEPTED}", :dependent => :destroy
  has_many :follower_friends, :class_name => "Friend", :foreign_key => "invited_id", :conditions => "status = #{Friend::PENDING}", :dependent => :destroy
  has_many :following_friends, :class_name => "Friend", :foreign_key => "inviter_id", :conditions => "status = #{Friend::PENDING}", :dependent => :destroy

  has_many :friends,   :through => :friendships, :source => :invited
  has_many :followers, :through => :follower_friends, :source => :inviter
  has_many :followings, :through => :following_friends, :source => :invited

  has_many :friendships_initiated_by_me, :class_name => "Friend", :foreign_key => "inviter_id", :conditions => ['inviter_id = ?', self.id]
  has_many :friendships_not_initiated_by_me, :class_name => "Friend", :foreign_key => "user_id", :conditions => ['invited_id = ?', self.id]
  has_many :occurances_as_friend, :class_name => "Friend", :foreign_key => "invited_id"

  # Comments and Blogs
  has_many :comments, :as => :commentable, :order => 'created_at desc', :dependent => :destroy
  has_many :blogs, :as => :newsable, :class_name => "NewsItem", :order => 'created_at desc', :dependent => :destroy
  has_many :content_pages, :foreign_key => 'creator_id', :order => 'updated_at desc', :dependent => :destroy
  has_many :news_items, :class_name => 'NewsItem', :foreign_key => 'creator_id', :dependent => :destroy

  # Entries
  has_many :entries, :dependent => :destroy
  has_many :entries_shared_by_me, :class_name => 'SharedEntry', :foreign_key => 'shared_by_id', :dependent => :destroy
  has_many :google_docs, :through => :shared_entries, :source => 'entry', :conditions => 'google_doc = true', :select => "*"
  has_many :public_google_docs, :through => :shared_entries, :source => 'entry', :conditions => 'google_doc = true AND public = true', :select => "*"
  has_many :public_shared_entries, :through => :shared_entries, :source => 'entry', :conditions => 'google_doc = false AND public = true', :select => "*"

  # Forums
  has_many :moderatorships, :dependent => :destroy
  has_many :forums, :through => :moderatorships, :order => "#{Forum.table_name}.name"

  has_many :posts, :dependent => :destroy
  has_many :topics, :dependent => :destroy
  has_many :monitorships, :dependent => :destroy
  has_many :monitored_topics, :through => :monitorships, :conditions => ["#{Monitorship.table_name}.active = ?", true], :order => "#{Topic.table_name}.replied_at desc", :source => :topic

  # items shared with the user
  has_many :shared_entries, :as => :destination, :order => 'created_at desc', :dependent => :destroy
  has_many :interesting_entries, :through => :shared_entries, :source => 'entry'

  # Photos
  has_many :photos, :as => :photoable, :order => 'created_at desc', :dependent => :destroy

  # pages
  has_many :pages, :as => :contentable, :class_name => 'ContentPage', :order => 'created_at desc', :dependent => :destroy

  # status
  has_many :status_updates, :dependent => :destroy
  
  #taggins
  has_many :taggings, :foreign_key => 'tagger_id', :dependent => :destroy
  
  # Skills
  has_and_belongs_to_many :grade_level_experiences

  # Language
  has_and_belongs_to_many :languages
  belongs_to :language

  # professional role
  belongs_to :professional_role

  # Interests
  has_and_belongs_to_many :interests

  # Location
  belongs_to :state
  belongs_to :country

  # Files - documents, photos, etc
  has_many :uploads, :as => :uploadable, :order => 'created_at desc', :dependent => :destroy
 
  has_many :shared_uploads, :as => :shared_uploadable, :order => 'created_at desc', :include => :upload, :dependent => :destroy
  has_many :uploads_shared_by_me, :class_name => 'SharedUpload', :foreign_key => 'shared_by_id'
  
  # Properties
  has_many :bag_property_values, :dependent => :destroy 
  has_many :properties, :class_name => 'BagProperty', :finder_sql => 'SELECT *, bag_properties.required, bag_property_values.svalue, bag_property_values.ivalue, COALESCE(bag_property_values.visibility, bag_properties.default_visibility) AS visibility, bag_properties.data_type, bag_properties.id AS bag_property_id FROM bag_properties LEFT OUTER JOIN bag_property_values ON bag_properties.id = bag_property_values.bag_property_id AND user_id = #{id} GROUP BY bag_properties.id ORDER BY sort, bag_properties.id'

  # Search
#  acts_as_solr :fields => [ :login, :first_name, :last_name ]  
  acts_as_solr :fields => [ :content_p,  :content_u, :content_f, :content_a ]  

  named_scope :by_login_alpha, :order => "login DESC"
  named_scope :by_last_name, :order => "last_name ASC"
  named_scope :by_newest, :order => "created_at DESC"
  named_scope :active, :conditions => "activated_at IS NOT NULL"
  named_scope :inactive, :conditions => "activated_at IS NULL"    
  named_scope :recent, lambda { { :conditions => ['created_at > ?', 1.week.ago] } }
  named_scope :by_login, lambda { |*args| { :conditions => ["login LIKE ?", args.first + '%'] } }

  def self.inactive_count
    User.count :conditions => "activated_at is null"
  end
  
  def self.activate_all
    User.update_all("activated_at = '#{Time.now}'", 'activated_at IS NULL')
  end
  
  def feed_to
    [self] | self.friends | self.followers # prevent duplicates in the array
  end
  
  def after_create
    self.status_updates.build(:text => _("%{name} joined %{application_name}") % {:name => self.full_name || self.login, :application_name => GlobalConfig.application_name})
    feed_item = FeedItem.create(:item => self, :creator_id => self.id)
    self.feed_items << feed_item
  end
  
  def status
    self.status_updates.find(:first, :order => 'created_at DESC')
  end
  
  def short_name
    self.first_name || self.login
  end
  
     
  def create_feed_item template = nil
    feed_item = FeedItem.create(:item => self, :creator_id => self.id, :template => template)
    feed_to.each{ |u| u.feed_items << feed_item }
  end
     
  file_column :icon, :magick => {
    :versions => { 
      :big => {:crop => "1:1", :size => "150x150", :name => "big"},
      :medium => {:crop => "1:1", :size => "100x100", :name => "medium"},
      :small => {:crop => "1:1", :size => "50x50", :name => "small"}
    }
  }

  before_save :encrypt_password, :lower_login, :query_services
  before_create :make_activation_code

  class ActivationCodeNotFound < StandardError; end
  class AlreadyActivated < StandardError
    attr_reader :user, :message;
    def initialize(user, message=nil)
      @message, @user = message, user
    end
  end

  def pledge_requests
    sql = 'SELECT groups.id AS group_id, groups.url_key, groups.name AS group_name, pledges.login, pledges.first_name, pledges.last_name, pledges.id, membership_requests.id AS membership_request_id ' + 
    'FROM memberships ' +
    'INNER JOIN membership_requests ON membership_requests.group_id = memberships.group_id AND memberships.user_id = ? AND role = \'manager\' '+ 
    'INNER JOIN groups ON groups.id = membership_requests.group_id ' + 
    'INNER JOIN users AS pledges ON pledges.id = membership_requests.user_id ' 
    User.find_by_sql([sql, self.id])
  end

# TODO remove boolean is_active field
# decide if can_mail and can_send are meaningful anymore
  def can_mail? user
    can_send_messages? && profile.is_active?
  end

  # Finds the user with the corresponding activation code, activates their account and returns the user.
  #
  # Raises:
  #  +User::ActivationCodeNotFound+ if there is no user with the corresponding activation code
  #  +User::AlreadyActivated+ if the user with the corresponding activation code has already activated their account
  def self.find_and_activate!(activation_code)
    raise ArgumentError if activation_code.nil?
    user = find_by_activation_code(activation_code)
    raise ActivationCodeNotFound if !user
    raise AlreadyActivated.new(user) if user.active?
    user.send(:activate!)
    user
  end

  def active?
    # the presence of an activation date means they have activated
    !activated_at.nil?
  end

  # Returns true if the user has just been activated.
  def pending?
    @activated
  end

  # checks to see if a given login is already in the database
  def self.login_exists?(login)
    if User.find_by_login(login).nil?
      false
    else
      true
    end
  end

  # checks to see if a given email is already in the database
  def self.email_exists?(email)
    if User.find_by_email(email).nil?
      false
    else
      true
    end
  end

  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  # Updated 2/20/08
  def self.authenticate(login, password)    
    u = find :first, :conditions => ['login = ? and activated_at IS NOT NULL', login] # need to get the salt
    u && u.authenticated?(password) ? u : nil
    # implement to add last logged in date
    #return nil if u.nil?                
    #u.logged_in_at = Time.now.utc
    #u.save(false) # don't validate.
    #u 
  end

  #lowercase all logins
  def lower_login
    self.login = self.login.nil? ? nil : self.login.downcase 
  end

  # Encrypts some data with the salt.
  def self.encrypt(password, salt)
    Digest::SHA1.hexdigest("--#{salt}--#{password}--")
  end

  # Encrypts the password with the user salt
  def encrypt(password)
    self.class.encrypt(password, salt)
  end

  def authenticated?(password)
    crypted_password == encrypt(password)
  end

  def remember_token?
    remember_token_expires_at && Time.now.utc < remember_token_expires_at
  end

  # These create and unset the fields required for remembering users between browser closes
  def remember_me
    remember_me_for 2.weeks
  end

  def remember_me_for(time)
    remember_me_until time.from_now.utc
  end

  def remember_me_until(time)
    self.remember_token_expires_at = time
    self.remember_token            = encrypt("#{email}--#{remember_token_expires_at}")
    save(false)
  end

  def forget_me
    self.remember_token_expires_at = nil
    self.remember_token            = nil
    save(false)
  end

  def forgot_password
    @forgotten_password = true
    self.make_password_reset_code
  end

  def reset_password
    # First update the password_reset_code before setting the
    # reset_password flag to avoid duplicate email notifications.
    update_attribute(:password_reset_code, nil)
    @reset_password = true
  end  

  #used in user_observer
  def recently_forgot_password?
    @forgotten_password
  end

  def recently_reset_password?
    @reset_password
  end

  def self.find_for_forget(email)
    find :first, :conditions => ['email = ?', email]
  end

  def has_role?(rolename)
    @roles ||= self.roles.map{|role| role.rolename}
    return false unless @roles
    @roles.include?(rolename)
  end

  def is_admin?
    has_role?('administrator')
  end

  def admin?
    is_admin?
  end
  
  def force_activate!
    @activated = true
    self.update_attribute(:activated_at, Time.now.utc)
  end

  def to_param
    "#{login.to_safe_uri}"
  end

  def has_network?
    !Friend.find(:first, :conditions => ["invited_id = ? or inviter_id = ?", id, id]).blank?
  end

  def full_name
    if self.first_name.blank? && self.last_name.blank?
      self.login rescue 'Deleted user'
    else
      ((self.first_name || '') + ' ' + (self.last_name || '')).strip
    end
  end

  def display_name
    self.login
  end
  
  def location
    return '' if attributes['location'].blank?
    attributes['location']
  end

  def f
    full_name
  end

  def moderator_of?(forum)
    moderatorships.count(:all, :conditions => ['forum_id = ?', (forum.is_a?(Forum) ? forum.id : forum)]) == 1
  end

  def to_xml(options = {})
    options[:except] ||= []
    options[:except] << :email << :crypted_password << :salt << :remember_token << :remember_token_expires_at << :activation_code
    options[:except] << :activated_at << :password_reset_code << :enabled << :terms_of_service << :can_send_messages << :identity_url
    options[:except] << :tmp_password << :protected_profile << :public_profile    
    super
  end
  
  def no_data?
    (created_at <=> updated_at) == 0
  end

  def has_wall_with profile
    return false if profile.blank?
    !Comment.between_users(self, profile).empty?
  end

  def website= val
    write_attribute(:website, UrlMethods::fix_http(val))
  end

  def blog= val
    write_attribute(:blog, UrlMethods::fix_http(val))
  end

  def flickr= val
    write_attribute(:flickr, UrlMethods::fix_http(val))
  end

  def query_services
    uri = read_attribute(:blog)
    rss_link = RssMethods::auto_detect_rss_url(uri)
    write_attribute(:blog_rss, rss_link) if rss_link
  end

  # Friend Methods
  def friend_of? user
    user.in? friends
  end

  def followed_by? user
    user.in? followers
  end

  def following? user
    user.in? followings
  end

  def self.search query = '', options = {}
    query ||= ''
    q = '*' + query.gsub(/[^\w\s-]/, '').gsub(' ', '* *') + '*'
    options.each {|key, value| q += " #{key}:#{value}"}
    arr = find_by_contents q, :limit=>:all
    logger.debug arr.inspect
    arr
  end

  # TODO might replace search above with this:
  # def self.search(query, options = {})
  #   with_scope :find => { :conditions => build_search_conditions(query) } do
  #     options[:page] ||= nil
  #     paginate options
  #   end
  # end
  # 
  # def self.build_search_conditions(query)
  #   query && ['LOWER(full_name) LIKE :q OR LOWER(login) LIKE :q', {:q => "%#{query}%"}]
  # end
  
  def self.currently_online
    User.find(:all, :conditions => ["last_seen_at > ?", Time.now.utc-5.minutes])
  end
  
  def update_posts_count
    self.class.update_posts_count id
  end
  
  def self.update_posts_count(id)
    User.update_all ['posts_count = ?', Post.count(:id, :conditions => {:user_id => id})],   ['id = ?', id]
  end
  
  def is_active?
    !activated_at.nil?
  end

  def can_edit?(user)
    return false if user.nil?
    self.id == user.id || user.is_admin?
  end
  
  # before filter
  def encrypt_password
    return if password.blank?
    self.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{login}--") if new_record?
    self.crypted_password = encrypt(password)
  end

  def password_required?
    not_openid? && (crypted_password.blank? || !password.blank?)
  end

  def not_openid?
    identity_url.blank?
  end

  def make_activation_code
    self.activation_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

  def make_password_reset_code
    self.password_reset_code = Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )
  end

  def content_p
    fields_visible_to BagProperty::VISIBILITY_EVERYONE
  end

  def content_u
    fields_visible_to BagProperty::VISIBILITY_USERS
  end

  def content_f
    fields_visible_to BagProperty::VISIBILITY_FRIENDS
  end

  def content_a
    fields_visible_to BagProperty::VISIBILITY_ADMIN
  end

  private
  
  def fields_visible_to threshold
    ([first_name, last_name, login, email] + properties_visible_to(threshold).collect{|p| p.value}).join(' ')
  end
  
  def activate!
    @activated = true
    self.update_attribute(:activated_at, Time.now.utc)
  end

end
