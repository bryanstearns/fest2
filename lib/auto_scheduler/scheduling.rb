module AutoScheduler::Scheduling
  def go
    while true do

      cost, screening, pick = @prioritized_available_screenings.shift || break

      schedule(pick, screening)
      @scheduled_count += 1
    end

    diagnose_problems if @scheduled_count == 0
    return (@scheduled_count + @old_picked_screening_count), @prioritized_count
  end

  def schedule(pick, screening)
    # Schedule this screening for this pick
    logit "pass #{@scheduled_count}: scheduling #{screening.inspect} at #{cost} for #{pick.priority rescue 'nil'}"

    raise(InternalAutoSchedulingError, "oops: scheduling against a picked screening!") \
      if @screening_conflicts[screening].any? {|s| @screening_to_pick[s].screening rescue false }

    pick.screening_id = screening.id
    pick.save!

    @screening_to_pick[screening] = pick

    def cleanup(screening)
      @screening_costs[screening] = nil
      @film_to_remaining_screenings[screening.film].delete(screening)
    end
    cleanup(screening)
    @screening_conflicts[screening].each { |s| cleanup(s) }
  end

  def diagnose_problems
    # Try to figure out why we didn't pick anything
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
end
