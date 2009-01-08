require File.dirname(__FILE__) + '/../test_helper'

class UploadTest < ActiveSupport::TestCase

  context "An Upload instance" do
    setup do
      @upload = uploads(:first)
    end

    should_have_many :comments
    should_belong_to :user

    should_have_named_scope :newest_first
    should_have_named_scope :alphabetic
    should_have_named_scope :recent
    should_have_named_scope :new_this_week
    should_have_named_scope :tagged_with
    should_have_named_scope :images
    should_have_named_scope :public
    should_have_named_scope :documents
    should_have_named_scope :files
             
    should "be an image" do
      assert @upload.is_image?
    end
    
    should "contain recent method" do
      Upload.recent
    end
    
    should "contain new_this_week method" do
      Upload.new_this_week
    end
    
    should "contain tagged_with method" do
      Upload.tagged_with('test')
    end
    
    should "contain owner method" do
      @upload.owner
    end
    
    should "contain max_upload_size method" do
      @upload.max_upload_size
    end
    
    should "contain find_recent method" do
      Upload.find_recent
    end
    
    should "contain type methods" do
      @upload.is_image?
      @upload.is_mp3?
      @upload.is_excel?
      @upload.is_pdf?
      @upload.is_word?
    end
    
    def self.find_recent(options = { :limit => 3 })
        self.new_this_week.find(:all, :limit => options[:limit])
    end
    
    context "quentin" do
      should "be able to edit" do
        assert @upload.can_edit?(users(:quentin))
      end

      should "be able to share with africa" do
        @upload.share_with_group(users(:quentin), groups(:africa).id)
        assert SharedUpload.find_by_upload_id_and_shared_uploadable_id(@upload.id, groups(:africa).id)
      end
      
      should "be able to share with aaron" do
        @upload.share_with_friend(users(:quentin), users(:aaron).id)
        assert SharedUpload.find_by_upload_id_and_shared_uploadable_id(@upload.id, users(:aaron).id)
      end
      
    end

    context "aaron" do
      should "not be able to edit" do
        assert !@upload.can_edit?(users(:aaron))
      end
    end

  end

  def test_associations
    _test_associations
  end

end
