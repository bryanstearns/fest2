class ActiveRecord::Base
  # Give all models access to the current user, both 
  # for doing constrained lookups and for storing whodunit.
  cattr_accessor :current_user
end
