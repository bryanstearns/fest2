# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.9' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

if $gems_rake_task # If we're in a rake gems:install or similar task (this is set by Rails, the $-sign makes it a global variable)
  # We stop the initializer to load the files from the /config/initializers dir. This is to disable the usage of plugins or gems in that code.
  puts 'Disabling the application initializers and plugins (rails_gem_base == true)'
  class Rails::Initializer
    def load_application_initializers; end
    def load_plugins; end
 end
end

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
  # You have to specify the :lib option for libraries, where the Gem name (sqlite3-ruby) differs from the file itself (sqlite3)
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"
  config.gem 'mysql', :version => "=2.8.1"
  config.gem 'system_timer', :version => "1.0"
  config.gem 'memcache-client', :version => "1.7.7", :lib => 'memcache'
  config.gem 'ZenTest', :version => "4.2.1", :lib => false # cached_model wants this !?
  config.gem 'hoe', :version => "2.4.0" # cached_model wants this
  config.gem 'cached_model', :version => "1.3.1"
  config.gem 'prawn', :version => "0.8.4"
  config.gem 'prawnto', :version => "0.0.4"
  config.gem 'icalendar', :version => "1.1.0"
  config.gem 'hoptoad_notifier', :version => "2.4.2"
  config.gem 'haml', :version => "3.0.24"
  config.gem "compass", :version => "0.10.5"
  config.gem "fancy-buttons", :version => "0.5.5"
  config.gem 'fastercsv', :version => '=1.5.3'

  config.gem 'capistrano', :version => '=2.5.19', :lib => false
  config.gem 'capistrano-ext', :version => '=1.2.1', :lib => false

  # Test stuff: here so that "rake gems:install" will install them
  config.gem 'rspec', :version => '1.3.1', :lib => false
  config.gem 'rspec-rails', :version => '1.3.3', :lib => false
  config.gem 'gherkin', :version => "2.3.7", :lib => false # cucumber wants this
  config.gem 'cucumber', :version => "0.10.0", :lib => false
  config.gem 'factory_girl', :version => "1.2.3", :lib => false

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Make Time.zone default to the specified zone, and make Active Record store time values
  # in the database in UTC, and return them converted to the specified local zone.
  # Run "rake -D time" for a list of tasks for finding time zone names. Comment line to use default local time.
  config.time_zone = 'Pacific Time (US & Canada)'

  # The internationalization framework can be changed to have another default locale (standard is :en) or more load paths.
  # All files from config/locales/*.rb,yml are added automatically.
  # config.i18n.load_path << Dir[File.join(RAILS_ROOT, 'my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :key => '_fest_session',
    :secret      => 'SESSION_SECRET_WAS_HERE'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with "rake db:sessions:create")
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # Please note that observers generated using script/generate observer need to have an _observer suffix
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer
  
  # BJS: Configure mailer
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    :tls => true,
    :address => 'smtp.gmail.com',
    :port => 587,
    :domain => 'festivalfanatic.com',
    :enable_starttls_auto => true,
    :authentication => :login,
    :user_name => 'festfan@festivalfanatic.com',
    :password => 'xXxXxXxXxXx'
  }
end
