require 'erb'

# load configurations from database.yml
database_yml_erb = File.read(File.join(File.dirname(__FILE__), 'database.yml'))
database_yml = ERB.new(database_yml_erb).result
ActiveRecord::Base.configurations = YAML.load(database_yml)

# set logfile
ActiveRecord::Base.logger = Logger.new(File.join(File.dirname(__FILE__), "debug.log"))

# load schema to each db
ActiveRecord::Base.configurations.keys.each do |c|
  ActiveRecord::Base.establish_connection(c.to_sym)
  load('schema.rb')
end

require "active_support"
require "database_rewinder"

# configure DatabaseRewinder <3
ActiveRecord::Base.configurations.keys.each do |c|
  DatabaseRewinder[c]
end
DatabaseRewinder.clean_all

# load fixtures to each db
ActiveRecord::Base.configurations.keys.each do |c|
  ActiveRecord::Base.establish_connection(c.to_sym)
  load('fixtures.rb')
end

ActiveRecord::Base.establish_connection(ENV['DB'] || :sqlite_db_0)