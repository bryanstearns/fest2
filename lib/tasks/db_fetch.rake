require 'yaml'
require 'erb'

namespace :db do
  desc "Download a copy of the remote production database and replace the loca development database"
  task :fetch do
    raise "Can't fetch into production" if RAILS_ENV == "production"
    puts "Recreating database"
    `r --create`
    puts "Importing production data"
    db_config = YAML::load(ERB.new(IO.read("config/database.yml")).result)
    `ssh selfamusementpark.com -p3386 "mysqldump -ufest -pfest --opt --skip-extended-insert fest_production" | mysql -ufest -pfest #{db_config[RAILS_ENV]["database"]}`
    puts "Migrating"
    Rake::Task['db:migrate'].invoke
    if RAILS_ENV == "development"
      puts "Cloning structure to test"
      Rake::Task['db:test:clone'].invoke
    end
  end
end
