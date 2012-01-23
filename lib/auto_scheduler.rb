require 'ruby-debug'

# Schedule prioritized but unscheduled films for this user
class AutoScheduler
  include Utilities
  include Initialization
  include Scheduling

  attr_accessor :all_screenings, :all_picks, :film_to_priority, :film_to_remaining_screenings,
                :pick_to_screenings, :prioritized_available_screenings, :scheduled_count,
                :screening_conflicts, :screening_costs, :screening_to_pick, :screenings_by_id
end
