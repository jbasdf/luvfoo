require "#{File.dirname(__FILE__)}/../test_helper"
require "#{File.dirname(__FILE__)}/../integration/integration_helper"

class BlogsTest < ActionController::IntegrationTest

  include IntegrationHelper

  def test_blogging
    new_session_as(:quentin) do |quentin| 
      quentin.views_blog_entries
      quentin.edits_blog_entry
      quentin.writes_blog_post            
    end
  end

  module BlogActions

    include IntegrationHelper::UserHelper

    def writes_blog_post
      goes_to("/users/#{users(:quentin).to_param}/blogs/new", "users/blogs/new")
    end

    def views_blog_entries
      goes_to("/users/#{users(:quentin).to_param}/blogs", "users/blogs/index")
    end

    def edits_blog_entry
      goes_to("/users/#{users(:quentin).to_param}/blogs/#{news_items(:blog_post).to_param}/edit", "users/blogs/edit")
    end

  end

  def new_session
    open_session do |sess|
      sess.extend(BlogActions)
      yield sess if block_given?
    end
  end

end