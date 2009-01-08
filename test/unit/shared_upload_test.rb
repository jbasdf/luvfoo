require File.dirname(__FILE__) + '/../test_helper'

class SharedUploadTest < ActiveSupport::TestCase

  context 'An shared upload instance' do
    should_belong_to :upload
    should_have_many :comments
  
    should 'share an upload with a group' do
      group = Factory(:group)
      assert_difference "SharedUpload.count" do
        assert_difference "FeedItem.count", 7 do # it s 7 because of all the objects the factory creates that then add to FeedItems
          @share = Factory(:shared_upload, :shared_uploadable => group)
        end
      end  
      assert group.shared_uploads.include?(@share)
    end
        
    should 'share an upload with a user' do
      user = Factory(:user)
      assert_difference "SharedUpload.count" do
        assert_difference "FeedItem.count", 7 do
          share = Factory(:shared_upload, :shared_uploadable => user)
          assert user.shared_uploads.include?(share)
        end
      end
    end
    
  end

  def test_associations
    _test_associations
  end

end
