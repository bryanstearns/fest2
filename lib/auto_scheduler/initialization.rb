module AutoScheduler::Initialization

  attr_accessor :all_screenings, :all_picks, :film_to_pick, :film_to_priority, :film_to_remaining_screenings,
                :pick_to_screenings, :prioritized_available_screenings, :scheduled_count,
                :screening_conflicts, :screening_costs, :screening_to_pick, :screenings_by_id

  def initialize(user, festival, options={})
    @user = user
    @festival = festival
    @options = options
    @scheduled_count = 0 # Haven't done anything yet.
    @debug = options[:debug]

    log_it "AutoScheduling setup for #{user.email}" do
      maybe_fake_time(options[:now] || ENV["FAKE_TIME"])
      unselect_screenings(options[:unselect] || "none")

      log_it "Collecting user visible screenings" do
        collect_user_visible_screenings
      end
      log_it "Caching travel times" do
        collect_travel_times
      end
      log_it "Collecting user picks and films" do
        collect_user_picks_and_films
      end
      log_it "Counting picks" do
        count_picks
      end
      log_it "Making maps" do
        make_screening_and_film_maps
      end
      log_it "Collecting conflicts" do
        collect_screening_conflicts
      end
      log_it "Collecting pickable screenings" do
        collect_pickable_screenings
      end
      log_it "Collecting remaining screenings by film" do
        collect_remaining_screenings_by_film
      end
    end
  end

  def maybe_fake_time(fake_time)
    # Pretend it's before the sample festival?
    @now = fake_time ? Time.zone.parse(fake_time) : Time.zone.now
  end

  def unselect_screenings(unselect_option)
    # Unselect any screenings that need unselecting
    return if unselect_option == "none"
    log_it "Unselecting screenings: #{unselect_option}" do
      @festival.reset_screenings(@user, unselect_option == "future")
    end
  end

  def collect_user_visible_screenings
    @all_screenings = @festival.screenings.select {|s| @user.can_see?(s) }
  end

  def collect_travel_times
    @festival.travel_intervals.interval_cache(@user)
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
    @all_screenings_by_date = @all_screenings.group_by {|s| s.starts.to_date }
  end

  def collect_screening_conflicts
    @screening_conflicts = @all_screenings.inject(Hash.new {|h,k| h[k] = []}) do |h, s|
      #h[s] = s.conflicts(@user, @all_screenings_by_date)
      h[s] = @all_screenings.select { |sx| s != sx and s.conflicts_with?(sx, @user) }
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
