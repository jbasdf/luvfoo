$:.reject! { |e| e.include? 'TextMate' }

ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'redgreen' unless ENV['TM_MODE']
require 'ostruct'
require 'mocha'
require 'factory_girl'
require File.expand_path(File.dirname(__FILE__) + '/factories')

# for testing uploaded files
# place any "already uploaded" files in a subdirectory within /test/ instead of overwriting production files.
FileColumn::ClassMethods::DEFAULT_OPTIONS[:root_path] = File.join(RAILS_ROOT, 'test', "public", 'system')

class Test::Unit::TestCase

  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false

  fixtures :all

  # Add more helper methods to be used by all tests here...

  @@association_test_exclusions = %w{LocalizationTest RequestLoggingTest UserPhotosTest
    UserPhotoshootPhotosTest PurchasedPhotosTest UserPhotoRatingsTest
    PhotoRatingsTest UserCommentsTest PhotoCommentsTest UserPurchasedPhotosTest
    ProUsersControllerTest PhotoSizeTest PhotoStoriesTest
    GuestTest EmailTest SystemMailerTest}


  def _test_associations
    if ['SpiderTest', 'Controller', 'ActiveSupport', 'ActionMailer'].any?{|x| self.class.to_s.include?(x)} ||
      @@association_test_exclusions.include?(self.class.to_s)
      return true
    end
    check_associations(self.class.to_s.gsub('Test', '').constantize)
  end

  def check_associations(m, ignore = [])
    @m = m.new
    ig = [ignore].flatten
    m.reflect_on_all_associations.each do |assoc|
      next if ig.any?{|i| i == assoc.name}
      assert_nothing_raised("*************\n#{assoc.name} caused an error\n*************") do
        @m.send(assoc.name, true)
      end
    end
    true
  end

  # 
  #   
  #   def test_roles
  #     return unless self.class.to_s.ends_with? 'ControllerTest'
  #     _test_actions self.class.to_s.gsub('ControllerTest', '') do |action|
  #       puts "No test for controller: #{self.class.to_s.gsub('ControllerTest', '')}, action: #{action}"
  #       case action
  #       when ''
  #       else
  # #        _test_action 'get', action, {}, 1, 200, false
  # #        _test_action 'get', action, {}, 3, 200, true
  #       end
  #     end
  #     assert false
  #   end

  def _test_action( method, action, options, user = nil, response = 200, includes_401 = false, debug = false)
    #    puts "#{method}, #{action}, #{options.inspect}, #{user}"
    h = {}
    h = {:user=>users(user)} if user.is_a?(Symbol)
    h = {:user=>user} if user.is_a?(Numeric)
    send(method, action.to_sym, options, h)
    puts @response.body if debug
    assert_response response
    assert @response.body.include?('It looks like you don\'t have permission to view this page.') if includes_401
    assert !@response.body.include?('It looks like you don\'t have permission to view this page.') unless includes_401
    recycle
  end

  def _test_actions(controller, options={})
    return unless block_given?
    exclude = Set.new((options[:except] || []).to_a | ['set_vars', 'wsdl', 'rescue_action', 'render_500', 'render_404', 'filter_parameters',
      'rescue_action_in_public', 'local_request?', 'allow_to', 'set_timezone', 'set_locale', 'uuid', 'tz', 'locale_from_header',
      'route_name', 'resource_source=', 'find_singleton=', 'name_prefix', 'respond_to_without_url_helper?', 'resource_name=',
      'resource_service_class', 'method_missing_with_url_helper', 'resources_name', 'name_prefix=', 'singleton',
      'resource_url_helper_method?', 'enclosing_loaders', 'respond_to_with_url_helper?', 'singleton=', 'resource_class=', 'resource_class',
      'route_name=', 'enclosing_loaders=', 'resource_service_class=', 'resource_name', 'resources_name=', 'find_singleton','resource_source',
      'tzz', 'pretty_print', 'pretty_print_inspect', 'pretty_print_cycle', 'pretty_inspect', 'pretty_print_instance_variables', 'simple_price',
      'is_lightbox_search?', 'current_user', 'set_cookie_domain'])
    exclude = exclude.map( &:to_s)
    controller_class = eval(Inflector.classify("#{controller}_controller"))
    controller_class.send(:action_methods).each do |method|
      next if exclude.include? method
      yield method
    end
  end

  def assert_models_equal(expected_models, actual_models, message = nil)
    to_test_param = lambda { |r| "<#{r.class}:#{r.to_param}>" }
    full_message = build_message(message, "<?> expected but was\n<?>.\n", 
      expected_models.collect(&to_test_param), actual_models.collect(&to_test_param))
    assert_block(full_message) { expected_models == actual_models }
  end
  
  def ensure_flash(val)
    assert_contains flash.values, val, ", Flash: #{flash.inspect}"
  end
  
  def ensure_home_page
    # make sure there is a default 'home' page in the system
    @site = Site.first
    @user = Factory(:user)
    @content_page = @site.pages.create(:url_key => 'home', :title => 'the home page', 
                                       :body_raw => 'the page body', :creator => @user)
  end

  # Teardown and setup - for quick recycling of env. within a single test
  def recycle; teardown; setup; end

  NOT_LOGGED_IN_MSG = /You must be logged in to access this feature/i
  PERMISSION_DENIED_MSG = /You don't have permission to do that/i
  
end

# turn off solr for tests
class ActsAsSolr::Post
  def self.execute(request)
    true
  end
end

include AuthenticatedTestHelper

# Add more helper methods to be used by all tests here...
def login_using_basic_auth
  @request.env['HTTP_AUTHENTICATION'] = ActionController::HttpAuthentication::Basic.encode_credntials("", "")
end
