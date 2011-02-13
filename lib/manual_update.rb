
module ManualUpdate
  def self.by(login_name)
    require 'ruby-debug'
    ActiveRecord::Base.transaction do
      puts "Running update..."
      yield self

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
