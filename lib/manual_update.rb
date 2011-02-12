
module ManualUpdate
  def self.by(login_name)
    require 'ruby-debug'
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.current_user = User.find_by_login!(login_name)
      PaperTrail.whodunnit = login_name

      puts "Running update..."
      yield self

      puts "Checking database validity..."
      site = "local" if Rails.env.development?
      unless Checker.check(:verbose => ENV["VERBOSE"],
                           :site => site)
        puts "Check failed... rolling back."
        raise ActiveRecord::Rollback
      end

      if ENV["DRY_RUN"]
        # note: DRY_RUN=1 must come before "ruby" on the command line!
        puts "Check passed, but DRY_RUN specified... rolling back."
        raise ActiveRecord::Rollback
      end
      puts "Check passed ... committed."
    end
  end

  def self.log(msg)
    Rails.logger.info(msg)
    puts msg
  end
end
