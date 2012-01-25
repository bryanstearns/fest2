require 'ruby-debug'

# Schedule prioritized but unscheduled films for this user
class AutoScheduler
  include Utilities
  include Initialization
  include Cost
  include Scheduling
end
