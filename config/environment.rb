# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.0.2' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Force all environments to use the same logger level
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random, 
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_indexApp_session',
    :secret      => '331e48108a572566e5415c598f8bd0e681b456029c469f4c1a8d279fd92c860f5400d21471c9e6c2ce96b2d8f467c0de31fbb1a7104122e02c401cc0b9194d2b'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper,
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
end

path = "/home/ubuntu/Ruby/www/indexApp/indexing/rel/"
puts "Loading dico..."
@@dico = File.new(path+"dico", File::RDONLY).readlines.collect! do |word| 
    word.chomp!
    word.split
end
puts "Dico loaded.\nLoading posting file..."
@@posting_file = File.new(path+"posting_file", File::RDONLY).readlines.collect! do |line| 
    line.chomp!
    line.split
end
puts "Posting file loaded.\nLoading listing..."
listing = File.new(path+"listing", File::RDONLY).readlines.collect! do |word| 
    word.chomp!
    word.split(":")
end
puts "Listing loaded."
@@stoplist = File.new(path+"stoplist", File::RDONLY).readlines.each { |word| word.chomp! }

@@list       = Hash.new
@@name       = Hash.new
@@pointed    = Hash.new

@@lmoy = 0
listing.each do |line| 
    @@lmoy += line[1].to_i
    @@list[line[0]]    = line[1]
    @@name[line[0]]    = line[2]
    @@pointed[line[0]] = line[3]
end
@@lmoy /= 110830
