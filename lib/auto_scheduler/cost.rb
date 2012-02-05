module AutoScheduler::Cost
  def collect_screenings_by_cost
    # Make a sorted list of all screenings, by cost
    @screening_costs = {}
    @prioritized_available_screenings = @all_screenings.map do |s|
      if s.starts < @now
        nil
      else
        c = @screening_costs[s] = screening_cost(s)
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

  def screening_cost(screening)
    # The full cost of picking this screening
    film = screening.film
    pick = @film_to_pick[film]
    return nil if pick.try(:picked?)

    conflict_costs = screening_conflict_costs(screening)

    # this screening is unpickable if any of its conflicts is picked.
    return nil if conflict_costs.include?(nil)

    # Base cost is the cost of missing out on the conflicts
    # If the cost was 0, give it a big discount, less
    # a bit for the number of free screenings; this makes sure
    # standalone screenings will get picked first.
    cost = conflict_costs.sum
    cost = -(10 - conflict_costs.count) if cost == 0

    # Decrease the cost by the user's priority of this film
    if pick
      cost -= (pick.priority || 0) / @film_to_remaining_screenings[film].count.to_f
    end
    cost
  end


  def screening_conflict_costs(screening)
    # Return an array of the costs of picking screenings conflicting with this one
    @screening_conflicts[screening].map do |conflict|
      conflict == screening ? 0 : screening_conflict_cost(conflict)
    end
  end

  def screening_conflict_cost(conflicting_screening)
    # The cost of picking a screening that conflicts with this one
    conflicting_film = conflicting_screening.film
    conflicting_pick = @film_to_pick[conflicting_film]
    if conflicting_pick.nil?
      # it's not prioritized or picked, so it's free to pick.
      cost = 0
    elsif conflicting_pick.screening
      # the conflicting film has a screening selected - if it's this screening,
      # the cost is infinite; otherwise, it's free.
      cost = conflicting_pick.screening == conflicting_screening ? nil : 0
    else
      # the conflicting film isn't picked - cost is its priority divided by the
      # number of pickable screenings remaining for it
      cost = (conflicting_pick.priority || 0) / @film_to_remaining_screenings[conflicting_film].count.to_f
    end
    cost
  end
end
