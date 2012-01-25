module AutoScheduler::Initialization

  attr_accessor :all_screenings, :all_picks, :film_to_pick, :film_to_priority, :film_to_remaining_screenings,
                :pick_to_screenings, :prioritized_available_screenings, :scheduled_count,
                :screening_conflicts, :screening_costs, :screening_to_pick, :screenings_by_id

  def initialize(user, festival, options={})
    @user = user
    @festival = festival
    @options = options
    @scheduled_count = 0 # Haven't done anything yet.

    maybe_fake_time(options[:now] || ENV["FAKE_TIME"])
    unselect_screenings(options[:unselect] || "none")
    collect_user_visible_screenings
    collect_user_picks_and_films
    count_picks
    make_screening_and_film_maps
    collect_screening_conflicts
    collect_pickable_screenings
    collect_remaining_screenings_by_film
    collect_screenings_by_cost

    # Make our to-do list: the prioritized picks without screenings selected,
    # for films that have remaining screenings
    #@prioritized_unselected_picks = @all_picks.select do |p|
    #  p.screening.nil? and (p.priority || 0) > 0 and @film_to_remaining_screenings[p.film]
    #end
  end

  def maybe_fake_time(fake_time)
    # Pretend it's before the sample festival?
    @now = fake_time ? Time.zone.parse(fake_time) : Time.zone.now
  end

  def unselect_screenings(unselect_option)
    # Unselect any screenings that need unselecting
    @festival.reset_screenings(@user, unselect_option == "future") \
      unless unselect_option == "none"
  end

  def collect_user_visible_screenings
    @all_screenings = @festival.screenings.select {|s| @user.can_see?(s) }
  end

  def collect_user_picks_and_films
    @all_picks = @festival.picks.find_all_by_user_id(@user.id, :include => :film)
  end

  def count_picks
    @old_picked_screening_count = 0
    @prioritized_count = 0
    @all_picks.each do |p|
      if p.priority and p.priority > 0
        @prioritized_count += 1
        @old_picked_screening_count += 1 if p.screening_id
      end
    end
  end

  def make_screening_and_film_maps
    # Build more indexes:
    # - All screenings, by id
    # - All picks, by film
    # - Screening to pick that references it
    @screenings_by_id = make_map(@all_screenings) {|s| [s.id, s] }
    @film_to_pick = make_map(@all_picks) {|p| [p.film, p] }
    @screening_to_pick = make_map(@all_picks) {|p| [p.screening, p] }
  end

  def collect_screening_conflicts
    @screening_conflicts = @all_screenings.inject(Hash.new {|h,k| h[k] = []}) do |h, s|
      h[s] = @all_screenings.select { |sx| s != sx and s.conflicts_with(sx) }
      h
    end
  end

  def collect_pickable_screenings
    # Note the screenings that are pickable (that is, they don't conflict with a selected screening)
    @pickable_screenings = @all_screenings.select do |s|
      if @screening_to_pick[s].try(:screening_id) == s.id # this screening is selected already
        false
      else
        !@screening_conflicts[s].any? {|cs| @screening_to_pick[s].try(:screening_id) == s.id }
      end
    end
  end

  def collect_remaining_screenings_by_film
    # Figure out what screenings remain available for each film
    @film_to_remaining_screenings = make_map_to_list(@all_screenings) do |s|
      [s.film, s] if s.starts > @now and @pickable_screenings.include?(s)
    end
  end
end
