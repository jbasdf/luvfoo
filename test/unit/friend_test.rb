require File.dirname(__FILE__) + '/../test_helper'

class FriendTest < ActiveSupport::TestCase

    context "A Friend instance" do
        should_belong_to :inviter
        should_belong_to :invited
    end

    should "be able to start and stop following users(:aaron)" do
        u3 = users(:friend_guy)
        u2 = users(:aaron)
        assert !u3.following?(u2)
        assert_difference "Friend.count" do
            Friend.add_follower(u3, u2)
            u2.reload
            u3.reload
            assert u3.following?(u2)
        end

        assert_difference "Friend.count", -1 do
            Friend.reset(u3, u2)
            u2.reload and u3.reload
            assert !u3.following?(u2)
        end
    end
  
    should "not create an association with the same user" do
        Friend.destroy_all    
        assert !Friend.add_follower(users(:quentin), users(:quentin))
        assert_equal 0, Friend.count
    end

    should "have friends" do
        assert users(:quentin).friends.any?{|f| f.id == users(:aaron).id || f.id == users(:friend_guy).id}
        assert !users(:quentin).friends.any?{|f| f.id == users(:follower_guy).id}
        assert users(:quentin).followings.any?{|f| f.id == users(:follower_guy).id}
        assert users(:aaron).friends.any?{|f| f.id == users(:quentin).id}
        assert users(:friend_guy).friends.any?{|f| f.id == users(:quentin).id}
        assert users(:friend_guy).followers.any?{|f| f.id == users(:aaron).id}
    end


    should "create a new fan assocication" do
        Friend.destroy_all

        assert Friend.add_follower(users(:quentin), users(:aaron))
        assert_equal 1, Friend.count
        assert !users(:quentin).reload.friend_of?(users(:aaron).reload)
        assert users(:quentin).following?(users(:aaron))
        assert users(:aaron).followed_by?(users(:quentin))
    end


    should "not find an following to turn into a friendship so just makes a fan" do
        Friend.destroy_all
        assert Friend.make_friends(users(:quentin), users(:aaron))
        assert_equal 1, Friend.count
        assert !users(:quentin).reload.friend_of?(users(:aaron).reload)
        assert users(:quentin).following?(users(:aaron))
        assert users(:aaron).followed_by?(users(:quentin))
    end


    should "turn a following into a friendship" do
        Friend.destroy_all
        assert Friend.add_follower(users(:quentin), users(:aaron))
        assert_equal 1, Friend.count

        assert Friend.make_friends(users(:aaron), users(:quentin))
        assert_equal 2, Friend.count

        users(:quentin).reload
        users(:aaron).reload

        assert users(:quentin).friend_of?(users(:aaron))
        assert users(:aaron).friend_of?(users(:quentin))
    end


    should "turn a following into a friendship2" do
        Friend.destroy_all
        assert Friend.add_follower(users(:quentin), users(:aaron))
        assert_equal 1, Friend.count

        assert Friend.make_friends(users(:quentin), users(:aaron))
        assert_equal 2, Friend.count

        users(:quentin).reload
        users(:aaron).reload

        assert users(:quentin).friend_of?(users(:aaron))
        assert users(:aaron).friend_of?(users(:quentin))
    end


    should "not find a friendship so can't stop being friends" do
        Friend.destroy_all
        assert !Friend.stop_being_friends(users(:quentin), users(:aaron))
    end


    should "stop being friends and not be a fan" do
        Friend.destroy_all
        assert Friend.add_follower(users(:quentin), users(:aaron))
        assert Friend.make_friends(users(:quentin), users(:aaron))
        assert_equal 2, Friend.count

        users(:quentin).reload
        users(:aaron).reload

        assert Friend.stop_being_friends(users(:quentin), users(:aaron))
        users(:quentin).reload
        users(:aaron).reload

        assert !users(:quentin).friend_of?(users(:aaron))
        assert !users(:quentin).following?(users(:aaron))
        assert users(:quentin).followed_by?(users(:aaron))

        assert !users(:aaron).friend_of?(users(:quentin))
        assert users(:aaron).following?(users(:quentin))
        assert !users(:aaron).followed_by?(users(:quentin))

    end

    should "not find a friendship so can't reset" do
        Friend.destroy_all
        assert_no_difference "Friend.count" do
            assert Friend.reset(users(:quentin), users(:aaron))
        end
    end

    should "reset friendship" do
        Friend.destroy_all
        assert Friend.add_follower(users(:quentin), users(:aaron))
        assert Friend.make_friends(users(:quentin), users(:aaron))
        assert_equal 2, Friend.count

        users(:quentin).reload
        users(:aaron).reload

        assert Friend.reset(users(:quentin), users(:aaron))
        assert_equal 1, Friend.count
        users(:quentin).reload
        users(:aaron).reload

        assert !users(:quentin).friend_of?(users(:aaron))
        assert !users(:quentin).following?(users(:aaron))
        assert users(:quentin).followed_by?(users(:aaron))
        assert !users(:quentin).following?(users(:aaron))

        assert !users(:aaron).friend_of?(users(:quentin))
        assert users(:aaron).following?(users(:quentin))
        assert !users(:aaron).followed_by?(users(:quentin))
        assert users(:aaron).following?(users(:quentin))
    end
    
    def test_associations
      _test_associations
    end
    
end