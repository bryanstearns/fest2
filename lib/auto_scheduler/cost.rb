module AutoScheduler::Cost
  def collect_screenings_by_cost
    # Make a sorted list of all screenings, by cost
    @screening_costs = {}
    @prioritized_available_screenings = @all_screenings.map do |s|
      if s.starts < @now
        nil
      else
        c = @screening_costs[s] = ScreeningCost.new(self, s).full_cost
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

  class ScreeningCost
    def initialize(auto_scheduler, screening)
      @auto_scheduler = auto_scheduler
      @screening = screening
    end

    def full_cost
      film = @screening.film
      pick = @auto_scheduler.film_to_pick[film]
      return nil if pick.try(:picked?)

      conflict_costs = collect_conflict_costs

      # this screening is unpickable if any of its conflicts is picked.
      return nil if conflict_costs.include?(nil)

      # Base cost is the cost of missing out on the conflicts
      # If the cost was 0, give it a big discount, less
      # a bit for the number of free screenings; this makes sure
      # standalone screenings will get picked first.
      cost = conflict_costs.sum
      cost = -(100 - conflict_costs.count) if cost == 0

      # Decrease the cost by the user's priority of this film
      if pick
        cost -= (pick.priority || 0) / @auto_scheduler.film_to_remaining_screenings[film].count.to_f
      end

      # discount if it's in the same location as an adjacent previous or next
      # picked screening
      before = picked_screening_before
      if @screening.location_id == before.try(:location_id) and
        ((@screening.starts - before.ends) < 2.hours)
        cost *= 0.5
      end
      after = picked_screening_after
      if @screening.location_id == after.try(:location_id) and
        ((after.starts - @screening.ends) < 2.hours)
        cost *= 0.5
      end

      cost
    end

    def picked_screening_before
      index = @auto_scheduler.picked_screening_by_starts.bsearch_lower_boundary {|s| s.starts <=> @screening.starts}
      return nil unless index && index > 0
      result = @auto_scheduler.picked_screening_by_starts[index-1]
      result
    end

    def picked_screening_after
      index = @auto_scheduler.picked_screening_by_ends.bsearch_upper_boundary {|s| s.ends <=> @screening.ends}
      return nil unless index
      result = @auto_scheduler.picked_screening_by_ends[index]
      result
    end

    def collect_conflict_costs
      # Return an array of the costs of picking screenings conflicting with this one
      @auto_scheduler.screening_conflicts[@screening].map do |conflict|
        conflict == @screening ? 0 : conflict_cost(conflict)
      end
    end

    def conflict_cost(conflicting_screening)
      # The cost of picking a screening that conflicts with this one
      conflicting_film = conflicting_screening.film
      conflicting_pick = @auto_scheduler.film_to_pick[conflicting_film]
      if conflicting_pick.nil?
        # it's not prioritized or picked, so it's free to pick.
        cost = 0
      elsif conflicting_pick.screening_id
        # the conflicting film has a screening selected - if it's this screening,
        # the cost is infinite; otherwise, it's free.
        cost = conflicting_pick.screening_id == conflicting_screening.id ? nil : 0
      else
        # the conflicting film isn't picked - cost is its priority divided by the
        # number of pickable screenings remaining for it
        cost = (conflicting_pick.priority || 0) / @auto_scheduler.film_to_remaining_screenings[conflicting_film].count.to_f
      end
      cost
    end

  end
end
