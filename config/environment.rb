# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.1.1' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

# Load a global constant so the initializers can use them
require 'ostruct'
require 'yaml'

# config = OpenStruct.new(YAML.load_file("#{RAILS_ROOT}/config/global_config.yml"))
# env_config = config.send(RAILS_ENV)
# config.common.update(env_config) unless env_config.nil?
# ::GlobalConfig = OpenStruct.new(config.common)

::GlobalConfig = OpenStruct.new(YAML.load_file("#{RAILS_ROOT}/config/global_config.yml")[RAILS_ENV])

begin

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use. To use Rails without a database
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Specify gems that this application depends on.
  # They can then be installed with "rake gems:install" on new installations.
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "aws-s3", :lib => "aws/s3"

  # please note that you will need to install RMagick for rake gems:install to work
  # here's some help: http://b.lesseverything.com/2007/9/26/installing-imagemagick-and-rmagick-on-mac-os-x
  config.gem 'luigi-activerecord-activesalesforce-adapter', :lib => 'active_record', :version => '2.1.0', :source => "http://gems.github.com"
  #config.gem 'avatar', :version => '0.0.5'
  config.gem 'gcnovus-avatar', :version=>"0.0.7", :lib => 'avatar'
  config.gem 'builder', :version => '>=2.1.2'
  config.gem 'colored', :version => '>=1.1'
  config.gem 'feed-normalizer', :version => '>=1.5.1'
  config.gem 'gettext', :version => '>=1.93.0'
  config.gem 'hoe', :version => '>=1.8.3'
  config.gem 'hpricot', :version => '>=0.6.161'
  config.gem 'mocha', :version => '>=0.5.6'
  config.gem 'RedCloth', :lib => 'redcloth', :version => '>=3.0.4'
  config.gem 'rflickr', :lib => 'flickr', :version => '>=2006.02.01'
  config.gem 'ruby-openid', :lib => 'openid', :version => '>=2.1.2'
  config.gem 'simple-rss', :version => '>=1.1'
  config.gem 'SystemTimer', :lib => 'system_timer', :version => '>=1.0'
  config.gem 'tzinfo', :version => '>=0.3.9'
  config.gem 'uuidtools', :version => '>=1.0.3'
  config.gem 'mislav-will_paginate', :version => '>=2.3.6', :lib => 'will_paginate', :source => 'http://gems.github.com'
  config.gem 'youtube-g', :lib => 'youtube_g', :version => '>=0.4.1'
  config.gem 'mini_magick', :version => '>=1.2.3'
  config.gem 'mime-types', :lib =>'mime/types', :version => '>=1.15'
  
  # Only load the plugins named here, in the order given. By default, all plugins
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  config.load_paths += %W( #{RAILS_ROOT}/app/sweepers )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Comment line to use default local time.
  config.time_zone = 'UTC'
  config.active_record.default_timezone = :utc

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random,
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => GlobalConfig.session_key,
    :secret      => GlobalConfig.session_secret
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with "rake db:sessions:create")
  config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector
  if ENV["DB_MIGRATION"] != "true"
    config.active_record.observers = :user_observer, :user_plone_observer
  end

end

# HACK: We rescue this block here because the line:
# config.active_record.observers = :user_observer, :user_plone_observer
# results in the User model to be loaded. This causes an error to be thrown
# when running rake db:migrate on an empty database. This is because
# acts_as_solr hits the database to try to figure out the data types 
# of the fields that it indexes. On a db without the user table, it fails.
# If there is a more elegant way to handle this, I am all ears :-)
rescue ActiveRecord::StatementInvalid => e
  if e.to_s.include?(".users' doesn't exist: SHOW FIELDS FROM `users`")
    puts e.to_s
    puts "If you are running migrations from an empty db, don't worry, this error is caused by act_as_solr and should be ignored"
  else
    raise e
  end
end


class << GlobalConfig
    def prepare_options_for_attachment_fu(options)
      attachment_fu_options = options.symbolize_keys.merge({:storage => options['storage'].to_sym, 
          :max_size => options['max_size'].to_i.megabytes})  
    end
end
