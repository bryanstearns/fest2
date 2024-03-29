module FestivalsHelper
  class ViewingInfo
    # Info about one viewing cell - not just the screening, but
    # also layout information.
    attr_reader :screening, :film, :space_before, :height, 
                :other_screenings, :screening_index, :screening_count

    cattr_accessor :show_ids, :sched_debug
    self.show_ids = false #Rails.env.development?
    
    def initialize(screening, space_before, height, show_press)
      @screening = screening
      @film = @screening.film
      @space_before = space_before.to_i
      @height = height.to_i
      film_screenings = @film.screenings.with_press(show_press)\
        .sort_by(&:starts)
      @screening_index = film_screenings.index(screening) + 1
      @screening_count = film_screenings.size
      @other_screenings = film_screenings.delete(screening)
    end
    
    def ordinalize
      return "once" if screening_count == 1
      position = (screening_index == screening_count) ? "last" : screening_index.ordinalize
      return "#{position} of #{screening_count}"
    end    

    def film_name
      name = film.name
      name = "[f#{film.id}, s#{screening.id}] #{name}" if self.show_ids
      name
    end

    def screening_times
      times = screening.times
      times = "[#{screening.id}] #{times}" if self.show_ids
      times
    end
  end
  
  class DayInfo
    # An accumulation of info supporting rendering of one day's grid
    attr_reader :date, :starts, :ends, :screenings,
                :start_minute, :minutes_long, 
                :hour_height, :minute_height, :grid_height, :padding_height,
                :venues, :venue_viewings, :venue_width
    attr_accessor :page_break_before
    
    def self.collect(festival, show_press)
      # Collect & return info about each day's screenings      
      screenings = festival.screenings.with_press(show_press).all(:include => :venue)
      screenings_by_date = screenings.group_by { |s| s.starts.date }
      screenings_by_date.map do |date, screenings| 
        DayInfo.new(date, screenings, show_press)
      end
    end
    
    def initialize(date, screenings, show_press)
      @date = date
      @screenings = screenings.sort_by(&:starts)

      # Figure out the start and end times for the day
      @starts = @screenings.min {|s1, s2| s1.starts <=> s2.starts }.starts.round_down
      @ends = @screenings.max {|s1, s2| s1.ends <=> s2.ends }.ends.round_up
      @start_minute = @starts.to_minutes
      @minutes_long = (@ends - @starts).to_minutes

      # Figure out grid geometry
      @hour_height = 50.0 # Height of one hour in the grid, in pixels
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
        @venue_viewings[venue_key] << ViewingInfo.new(s, space_before, height, show_press)
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
  
  def days(festival, show_press, first_date=nil)
    # Collect & return info about each day's screenings
    days = DayInfo.collect(festival, show_press).sort_by do |d|
      first_date ? d.date + (d.date < first_date ? 60.days : 0) : d.date
    end
    
    # Insert page breaks
    page_height = 0
    days.each do |day|
      day_height = day.grid_height + 100
      page_height += day_height
      if page_height > 1000
        day.page_break_before = true
        page_height = day_height
      end
    end
    
    days
  end

  def readonly_festival_url(format = nil)
    festival_user_url(@festival.to_param,
                      :other_user_id => @displaying_user.to_param,
                      :key => @displaying_user_subscription.key,
                      :format => format)
  end

  def user_ratings_url(format = nil)
    festival_user_ratings_url(@festival.to_param,
                              :other_user_id => @displaying_user.to_param)
  end

  def icalendar_festival_url
    readonly_festival_url(:ics)
  end

  def google_festival_url
    "http://www.google.com/calendar/render?cid=" + 
      readonly_festival_url(:ics)
  end

  def yahoo_festival_url
    "http://add.my.yahoo.com/content?.intl=us&url=" +
      readonly_festival_url(:ics)
  end
end
