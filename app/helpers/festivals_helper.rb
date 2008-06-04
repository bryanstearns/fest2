require 'ruby-debug'

module FestivalsHelper
  class ViewingInfo
    # Info about one viewing cell - not just the screening, but
    # also this user's ranking of the film and layout information.
    attr_reader :screening, :film, :pick, :space_before, :height, 
                :other_screenings, :screening_index, :screening_count
    
    def initialize(screening, pick, space_before, height)
      @screening = screening
      @film = @screening.film
      @pick = pick
      @space_before = space_before.to_i
      @height = height.to_i
      film_screenings = @film.screenings.sort_by(&:starts)
      @screening_index = film_screenings.index(screening) + 1
      @screening_count = film_screenings.size
      @other_screenings = film_screenings.delete(screening)
    end
    
    def pick_state
      return "unranked" if pick.nil?
      return "scheduled" if pick.screening_id == @screening.id
      return "otherscheduled" if pick.screening_id
      return "unranked" if pick.priority.nil?
      return "unscheduled" if pick.priority > 0
      return "unranked"
    end
    
    def tooltip
      return "You haven't prioritized this film." if pick.nil?
      return "You're scheduled to see this screening." if pick.screening_id == @screening.id
      return "You're seeing this on #{pick.screening.date_and_times}." if pick.screening_id
      return "You haven't prioritized this film." if pick.priority.nil?
      return "You prioritized this, but no screening is selected." if pick.priority > 0
      return "You gave this the lowest priority."
    end
    
    def ordinalize
      return "once" if screening_count == 1
      position = (screening_index == screening_count) ? "last" : screening_index.ordinalize
      return "#{position} of #{screening_count}"
    end
    
    def priority
      (pick.priority || 0) rescue 0
    end
  end
  
  class DayInfo
    # An accumulation of info supporting rendering of one day's grid
    attr_reader :date, :starts, :ends, :screenings,
                :start_minute, :minutes_long, 
                :hour_height, :minute_height, :grid_height, :padding_height,
                :venues, :venue_viewings, :venue_width
    attr_accessor :page_break_before
    
    def self.collect(festival, picks, conference_mode)
      # Collect & return info about each day's screenings      
      pick_map = picks.index_by() { |p| p.film_id }
      screenings_by_date = festival.screenings.group_by { |s| s.starts.date }
      screenings_by_date.map do |date, screenings| 
        DayInfo.new(date, screenings, pick_map, conference_mode)
      end
    end
    
    def initialize(date, screenings, pick_map, conference_mode)
      @date = date
      @screenings = screenings.sort_by(&:starts)
      @pick_map = pick_map

      # Figure out the start and end times for the day
      @starts = @screenings.min {|s1, s2| s1.starts <=> s2.starts }.starts.roundDown
      @ends = @screenings.max {|s1, s2| s1.ends <=> s2.ends }.ends.roundUp
      @start_minute = @starts.to_minutes
      @minutes_long = (@ends - @starts).to_minutes

      # Figure out grid geometry
      @hour_height = conference_mode ? 70.0 : 50.0 # Height of one hour in the grid, in pixels
      @padding_height = 9.0 # Padding we add around the screening
      @minute_height = hour_height / 60.0
      @grid_height = @minutes_long * minute_height

      # Lay out viewings on the grid, indexed by venue
      @venue_viewings = Hash.new() { |h,k| h[k] = [] }
      next_time = {}
      @screenings.each do |s|
        start_minutes = s.starts.to_minutes
        room_index = -1
        begin
          room_index += 1
          raise(TooManyVenueConflicts, s.inspect) if room_index > 10
          venue_key = [s.venue, room_index]
          time_before = start_minutes - next_time.fetch(venue_key, @start_minute)
        end while next_time.include?(venue_key) and (time_before < 0)
        space_before = time_before * minute_height
        time_during = s.duration.to_minutes
        height = (time_during * minute_height) - padding_height
        @venue_viewings[venue_key] << ViewingInfo.new(s, @pick_map[s.film_id], space_before, height)
        next_time[venue_key] = start_minutes + time_during
      end
      
      # Measure the column widths
      @venues = @venue_viewings.keys.sort_by {|v| [v[0].abbrev, v[1]] }
      @venue_width = 100 / @venues.length
      
      @page_break_before = false
    end
    
    def scale(time)
      ((time.to_minutes - @start_minute) * @minute_height).to_i
    end
  end
  
  def days(festival, picks, conference_mode)
    # Collect & return info about each day's screenings
    today = Date.today
    days = DayInfo.collect(festival, picks, conference_mode).sort_by { |d| d.date + (d.date < today ? 60.days : 0) }
    
    # Insert page breaks
    time_on_page = 0
    days.each do |day|
      time_on_page += day.minutes_long
      if time_on_page > (12 * 60)
        time_on_page = day.minutes_long
        day.page_break_before = true
      end
    end
    
    days
  end
end
