require File.dirname(__FILE__) + '/../test_helper'

class UserTest < Test::Unit::TestCase

  context 'A user instance' do
    should_have_many :friendships
    # TODO uncomment these when shoulda adds support for source
    #should_have_many :friends, :through => :friendships, :source => :invited
    #should_have_many :followers, :through => :follower_friends
    #should_have_many :followings, :through => :following_friends
    should_have_many :follower_friends
    should_have_many :following_friends
    should_have_many :comments, :blogs
    should_have_many :pages
    
    should_have_many :moderatorships
		should_have_many :forums
		should_have_many :posts
		should_have_many :topics
		should_have_many :monitorships
		should_have_many :monitored_topics, :through => :monitorships
                
    should_require_unique_attributes :login, :email
    should_require_attributes :login, :email, :first_name, :last_name 

    should_ensure_length_in_range :password, (4..40)
    should_ensure_length_in_range :login, (3..40)

    should_have_many :permissions
    should_have_many :roles, :through => :permissions

    should_have_many :events
    should_have_many :event_users
    should_have_many :attending_events
    
    should_protect_attributes :crypted_password, :salt, :remember_token, :remember_token_expires_at, :activation_code, :activated_at,
                              :password_reset_code, :enabled, :can_send_messages, :is_active, :created_at, :updated_at, :plone_password,
                              :posts_count

    should_ensure_length_in_range :email, 6..100 #, :short_message => 'does not look like a valid email address.', :long_message => 'does not look like a valid email address.'
    should_allow_values_for :email, 'a@x.com', 'de.veloper@example.com'
    should_not_allow_values_for :email, 'example.com', '@example.com', 'developer@example', 'developer', :message => 'does not look like a valid email address.'

    should_not_allow_values_for :login, 'test guy', 'test.guy', 'testguy!', 'test@guy.com', :message => 'may only contain letters, numbers or a hyphen.'
    should_allow_values_for :login, 'testguy', 'test-guy'
    
    should_have_named_scope :by_login_alpha, :order => "login DESC"
    should_have_named_scope :by_newest, :order => "created_at DESC"
    should_have_named_scope :active, :conditions => "activated_at IS NOT NULL"
    should_have_named_scope :inactive, :conditions => "activated_at IS NULL" 
    should_have_named_scope 'recent(1.day.ago)'
    should_have_named_scope "by_login('a')" 
    
  end
  
  should "Create a new user and a feed item" do
    assert_difference 'User.count' do
      assert_difference 'FeedItem.count' do
        user = Factory(:user)
        assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
      end
    end
  end

  should "have full name" do
    assert_difference 'User.count' do
      user = Factory(:user, :first_name => 'quent', :last_name => 'smith')
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
      assert user.full_name == 'quent smith'
    end
  end
  
  should "have display name" do
    assert_difference 'User.count' do
      user = Factory(:user, :login => 'quentguy')
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
      assert user.display_name == 'quentguy'
    end
  end
  
  should "Create a new user and lowercase the login" do
    assert_difference 'User.count' do
      user = Factory(:user, :login => 'TESTGUY')
      assert !user.new_record?, "#{user.errors.full_messages.to_sentence}"
      assert user.login == 'testguy'
    end
  end

  should "Not allow login with dot" do
    user = Factory.build(:user, :login => 'test.guy')
    assert !user.valid?
  end

  should "Not allow login with dots" do
    user = Factory.build(:user, :login => 'test.guy.guy')
    assert !user.valid?
  end

  should "Allow login with dash" do
    user = Factory.build(:user, :login => 'test-guy')
    assert user.valid?
  end

  should "Not allow login with '@'" do
    user = Factory.build(:user, :login => 'testguy@example.com')
    assert !user.valid?
  end         

  should "Not allow login with '!'" do
    user = Factory.build(:user, :login => 'testguy!')
    assert !user.valid?
  end

  should "be in the admin role" do
    admin = users(:admin)
    assert admin.is_admin?
  end
  
#  should "Fail to create a new user because they didn't agree to terms of service" do
#    assert_no_difference 'User.count' do
#      user = Factory.build(:user, :terms_of_service => false)
#      assert user.new_record?, "#{user.errors.full_messages.to_sentence}"
#    end
#  end

  should "initialize activation code upon creation" do
    user = Factory(:user)
    assert_not_nil user.activation_code
  end

  should "require login" do
    assert_no_difference 'User.count' do
      u = Factory.build(:user, :login => nil)
      assert !u.valid?
      assert u.errors.on(:login)
    end
  end

  should "require password" do
    assert_no_difference 'User.count' do
      u = Factory.build(:user, :password => nil)
      assert !u.valid?
      assert u.errors.on(:password)
    end
  end

  should "require password confirmation" do
    assert_no_difference 'User.count' do
      u = Factory.build(:user, :password_confirmation => nil)
      assert !u.valid?
      assert u.errors.on(:password_confirmation)
    end
  end

  should "require require email" do
    assert_no_difference 'User.count' do
      u = Factory.build(:user, :email => nil)
      assert !u.valid?
      assert u.errors.on(:email)
    end
  end

  should "be able to reset their password" do
    assert_not_equal false, users(:quentin).update_attributes(:email => "hiapal@hotmail.com", :password => 'new password', :password_confirmation => 'new password')
    assert_equal users(:quentin), User.authenticate('quentin', 'new password')
  end

  should "not rehash password" do
    user = users(:quentin)
    hashed_password = user.crypted_password
    user.update_attributes(:login => 'quentin2')
    assert_equal hashed_password, user.crypted_password
  end

  should "authenticate user" do
    assert_equal users(:quentin), User.authenticate('quentin', 'test')
  end

  should "set remember token" do
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
  end

  should "unset remember token" do
    users(:quentin).remember_me
    assert_not_nil users(:quentin).remember_token
    users(:quentin).forget_me
    assert_nil users(:quentin).remember_token
  end

  should "remember me for one week" do
    before = 1.week.from_now.utc
    users(:quentin).remember_me_for 1.week
    after = 1.week.from_now.utc
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert users(:quentin).remember_token_expires_at.between?(before, after)
  end

  should "remember me until one week" do
    time = 1.week.from_now.utc
    users(:quentin).remember_me_until time
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert_equal users(:quentin).remember_token_expires_at, time
  end

  should "remember me default two weeks" do
    before = 2.weeks.from_now.utc
    users(:quentin).remember_me
    after = 2.weeks.from_now.utc
    assert_not_nil users(:quentin).remember_token
    assert_not_nil users(:quentin).remember_token_expires_at
    assert users(:quentin).remember_token_expires_at.between?(before, after)
  end

  # test friendships
  context 'users(:quentin)' do
    should 'be friends with users(:aaron)' do
      assert users(:quentin).friend_of?( users(:aaron) )
      assert users(:aaron).friend_of?( users(:quentin) )
    end

    should 'be following users(:follower_guy)' do
      assert users(:quentin).following?( users(:follower_guy) )
      assert users(:follower_guy).followed_by?( users(:quentin) )
    end
  end

  should "get a list of other users to share activity feed with" do
    share_with = users(:quentin).feed_to
    assert share_with.include?(users(:quentin))
    assert share_with.include?(users(:aaron))
  end
  
  should "get rss links for blog" do
    u = Factory.build(:user)
    u.blog = "http://www.justinball.com"
  end

  #    should "prefix with http" do
  #        p = users(:quentin)
  #        assert p.website.nil?
  #        assert p.website = 'example.com'
  #        assert p.save
  #        assert_equal 'http://example.com', p.reload.website
  #    end
  #
  #    should "prefix with http4" do
  #        p = users(:quentin)
  #        assert p.website.nil?
  #        assert p.website = ''
  #        assert p.save
  #        assert_equal '', p.reload.website
  #    end
  #
  #    should "prefix with http2" do
  #        p = users(:quentin)
  #        assert p.blog.nil?
  #        assert p.blog = 'example.com'
  #        assert p.save
  #        assert_equal 'http://example.com', p.reload.blog
  #    end
  #
  #    should "prefix with friend_guy" do
  #        p = users(:quentin)
  #        assert p.flickr.nil?
  #        assert p.flickr = 'example.com'
  #        assert p.save
  #        assert_equal 'http://example.com', p.reload.flickr
  #    end

  should "have wall with aaron" do
    assert users(:quentin).has_wall_with(users(:aaron))
  end

  should "not have wall with friend_guy" do
    assert !users(:quentin).has_wall_with(users(:friend_guy))
  end

  def test_associations
    _test_associations
  end

  protected

  def call_methods(user)
    
    user.friendships
    user.follower_friends
    user.following_friends

    user.friends
    user.followers
    user.followings

    user.friendships_initiated_by_me
    user.friendships_not_initiated_by_me
    user.occurances_as_friend
    
    user.pledge_requests
    user.active?
    
  end
  
end
