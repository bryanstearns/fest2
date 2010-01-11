require 'yaml'
require 'erb'

namespace :db do
  desc "Download a copy of the remote production database and replace the loca development database"
  task :fetch do
    pre_fetch

    puts "Retrieving production data"
    `ssh selfamusementpark.com -p3386 "mysqldump -ufest -pfest --opt --skip-extended-insert fest_production" > tmp/production.sql`
    post_fetch
  end
  
  task :refetch do
    pre_fetch
    post_fetch
  end

  def pre_fetch
    raise "Can't refetch into production" if RAILS_ENV == "production"
    puts "Recreating database"
    `r --create`
  end

  def post_fetch
    puts "Loading data"
    db_config = YAML::load(ERB.new(IO.read("config/database.yml")).result)
    `mysql -ufest -pfest #{db_config[RAILS_ENV]["database"]} <tmp/production.sql`
    puts "Migrating"
    Rake::Task['db:migrate'].invoke
    Rake::Task['db:check'].invoke
    if RAILS_ENV == "development"
      puts "Cloning structure to test"
      Rake::Task['db:test:clone'].invoke
    end
  end
end
