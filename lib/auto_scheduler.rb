require 'ruby-debug'

# Schedule prioritized but unscheduled films for this user
class AutoScheduler
  attr_accessor :all_screenings, :all_picks, :screenings_by_id,
                :screening_to_pick, :film_to_priority, :prioritized_unselected_picks,
                :pick_to_screenings, :pick_to_remaining_screenings,
                :screening_costs, :screening_conflicts
    
  def logit msg
    puts msg
    RAILS_DEFAULT_LOGGER.info msg
    true # so we can do "logit xxx and return"
  end

  def make_map(a)
    a.inject({}) do |h, x|
      k, v = yield x
      h[k] = v if k and v
      h
    end
  end
    
  def make_map_to_list(a)
    a.inject(Hash.new {|h, k| h[k] = []}) do |h, x|
      pair = yield x
      if pair
        k, v = pair
        h[k] << v if k and v
      end
      h
    end
  end
    
  def initialize(user, festival, unselect)
    # Pretend it's before the sample festival
    @now = Time.now # - (Time.now.year - 1996).years

    # Unselect any screenings that need unselecting
    festival.reset_screenings(user, unselect == "future") \
      unless unselect == "none"

    # Load this user's unscheduled-but-prioritized picks; also load each film, and 
    # all future screenings of that film that the user can see.
    @all_screenings = Screening.find_all_by_festival_id(festival.id)\
      .select {|s| user.can_see?(s) }
    @all_picks = Pick.find_all_by_festival_id_and_user_id(festival.id, user.id, :include => :film)
    @old_picked_screening_count = 0
    @prioritized_count = 0
    @all_picks.each do |p|
      if p.priority and p.priority > 0
        @prioritized_count += 1
        @old_picked_screening_count += 1 if p.screening_id
      end
    end
    
    # Build more indexes:
    # - All screenings, by id
    # - All picks, by film
    # - Screening to pick that references it
    @screenings_by_id = make_map(@all_screenings) {|s| [s.id, s] }
    @film_to_pick = make_map(@all_picks) {|p| [p.film, p] }
    @screening_to_pick = make_map(@all_picks) {|p| [p.screening, p] }
    
    # Note the conflictors with each screening
    @screening_conflicts = @all_screenings.inject(Hash.new {|h,k| h[k] = []}) do |h, s|
      h[s] = @all_screenings.select { |sx| s != sx and s.conflicts_with(sx) }
      h
    end

    # Calculate the cost of each screening
    @screening_costs = @all_screenings.inject({}) do |h, s|
      h[s] = screening_cost(s)
      h
    end
    
    # Figure out what screenings remain available for each film
    @film_to_remaining_screenings = make_map_to_list(@all_screenings) do |s| 
      [s.film, s] if s.starts > @now and not @screening_costs[s].nil?
    end
    
    # Make our to-do list: the prioritized picks without screenings selected,
    # for films that have remaining screenings
    @prioritized_unselected_picks = @all_picks.select do |p| 
      p.screening.nil? and (p.priority || 0) > 0 and @film_to_remaining_screenings[p.film]
    end
  end
  
  def screening_cost(screening, verbose=false)
    # The cost of picking this screening is the sum of the costs of its conflicts,
    # or nil if it or any conflict is already picked
    pick = @film_to_pick[screening.film]
    return nil if pick and not pick.screening.nil?
    
    def screening_conflict_cost(conflicting_screening, verbose)
      # The cost of picking a screening that conflicts with this one
      conflicting_pick = @film_to_pick[conflicting_screening.film]
      if conflicting_pick.nil? # not prioritized or picked
        cost = 0 # free!
      elsif conflicting_pick.screening
        # this pick has a screening - if it's this screening, cost is infinite; otherwise,
        # it's free.
        cost = conflicting_pick.screening == conflicting_screening ? nil : 0
      else
        # Film isn't picked - cost is its priority.
        cost = conflicting_pick.priority || 0
      end
      puts "conflict cost of #{conflicting_screening.inspect} is #{cost}" if verbose
      cost
    end
    conflict_costs = @screening_conflicts[screening].map do |s| 
      puts "conflict: #{s.inspect}" if verbose
      s == screening ? 0 : screening_conflict_cost(s, verbose)
    end
    if conflict_costs.include?(nil)
      puts "cost of #{screening.inspect} is nil." if verbose
      return nil
    end
    cost = conflict_costs.sum
    cost -= (pick.priority || 0) if pick and pick.screening.nil?
    puts "cost of #{screening.inspect} is #{cost}" if verbose
    cost
  end
    
  def schedule(pick, screening)
    # Schedule this screening for this pick
    if @screening_conflicts[screening].any? {|s| @screening_to_pick[s].screening rescue false }
      logit "oops: scheduling against a picked screening!"
    end
    # logit "scheduling #{screening.inspect} for #{pick}"
    pick.screening_id = screening.id
    pick.save!
    
    @prioritized_unselected_picks.delete(pick)
    @screening_to_pick[screening] = pick
    
    def cleanup(screening)
      # logit "#{screening.inspect} is no longer available"
      @screening_costs[screening] = nil
      @film_to_remaining_screenings[screening.film].delete(screening)
    end
    cleanup(screening)
    @screening_conflicts[screening].each { |s| cleanup(s) }
  end

  def resort
    # Make a list of all screenings, by cost
    @prioritized_available_screenings = @all_screenings.map do |s|
      if s.starts < @now
        nil
      else
        c = screening_cost(s)
        if c.nil?
          nil
        else
          pick = @film_to_pick[s.film]
          (pick.nil? or ((pick.priority || 0) == 0)) \
            ? nil : [c, s, pick, @screening_conflicts[s]]
        end
      end
    end.compact.sort_by {|x| x[0] }
  end
  
  def resort_prioritized_unselected_picks
    # Sort the picks by priority, then by the number of remaining screenings.
    @prioritized_unselected_picks = @prioritized_unselected_picks.sort_by \
      { |p| ((p.priority||0) * 10) - @film_to_remaining_screenings[p.film].size }
  end

  def go
    scheduled_count = 0
    while true do
      resort
      cost, screening, pick = @prioritized_available_screenings.shift || break
      logit "pass #{scheduled_count}: scheduling #{screening.inspect} at #{cost} for #{pick.priority rescue 'nil'}"
      schedule(pick, screening)
      scheduled_count += 1
    end
    if scheduled_count == 0
      # Try to figure out what went wrong
      pick_count = 0 # has the user picked anything?
      unscheduled_pick_count = 0 # are any of the picks still unscheduled?
      future_screening_count = 0 # are any of the screenings still in the future?
      future_picked_screening_count = 0 # are any of the screenings still in the future?
      @all_picks.each do |p|
        if (p.priority ||0) > 0
          pick_count += 1
          unscheduled_pick_count += 1 if p.screening_id.nil?
        end
      end
      raise(AutoSchedulingError, "You haven't prioritized any films yet - do that (under the Films tab), then auto-schedule again.") \
        if pick_count == 0
      raise(AutoSchedulingError, "All of the films you've prioritized are already scheduled.") \
        if unscheduled_pick_count == 0
      @all_screenings.each do |s|
        if s.starts > @now
          future_screening_count += 1 
          pick = @film_to_pick[s.film]
          future_picked_screening_count +=1 if pick and (pick.priority||0) > 0
        end
      end
      raise(AutoSchedulingError, "This festival already concluded, so no screenings can be picked.") \
        if future_screening_count == 0                
      raise(AutoSchedulingError, "All of the screenings of your prioritized films have already happened.") \
        if future_picked_screening_count == 0
      raise(AutoSchedulingError, "No prioritized unscheduled films have upcoming screenings")
    end
    return (scheduled_count + @old_picked_screening_count), @prioritized_count
  end
end
