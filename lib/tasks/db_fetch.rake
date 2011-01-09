require 'yaml'
require 'erb'

namespace :db do
  desc "Download a copy of the remote production database and replace the " +
       "local development database"
  task :fetch do
    puts "Retrieving production data"
    `ssh selfamusementpark.com -p3386 "mysqldump -ufest -pfest --opt --skip-extended-insert fest_production" > production.sql`
    load_data
  end
  
  desc "Replace the local development database with a previously-downloaded " +
       "copy of the remote production database"
  task :load do
    load_data
  end

  def load_data
    raise "Can't refetch into production" if RAILS_ENV == "production"
    puts "Recreating database"
    `r --create`

    puts "Loading data"
    db_config = YAML::load(ERB.new(IO.read("config/database.yml")).result)
    `mysql -ufest -pfest #{db_config[RAILS_ENV]["database"]} <production.sql`
    puts "Migrating"
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:check'].invoke
    if RAILS_ENV == "development"
      puts "Cloning structure to test"
      Rake::Task['db:test:clone'].invoke
    end
  end
end
