require 'ruby-debug'

class Screening < CachedModel
  belongs_to :film
  belongs_to :festival
  belongs_to :venue
  belongs_to :location

  has_many :picks, :dependent => :nullify

  before_update :notify_users_of_change
  before_destroy :notify_users_of_cancellation

  before_validation :check_foreign_keys, :check_duration
  validates_presence_of :festival_id
  validates_presence_of :film_id
  validates_presence_of :venue_id
  validates_presence_of :location_id
  validates_presence_of :starts
  validates_presence_of :ends
  validates_each [:ends] do |record, attrib, value|
    if !value.nil? and !record.starts.nil? and value < record.starts
      record.errors.add(attrib, "isn't after Starts")
    end
  end
  
  named_scope :with_press, lambda {|on| on ? {} : { :conditions => ['press = ?', false] } }

  # When testing screenings for conflict, we'll assume no conflict if there's at least this much time
  # between them
  MAX_TRAVEL_TIME = 2.hours

  def duration
    ends - starts
  end

  def inspect
    festival_name = festival.slug rescue "nil"
    film_name = film.name rescue "nil"
    venue_name = venue.name rescue "nil"
    "#<Screening id: #{id}, festival: #{festival_name}, film: #{film_name}, times: #{starts.to_date} #{times.gsub(/\s/, '')}, venue: #{venue_name}, press: #{press.inspect}>"
  end
  
  def times(in_parts=false)
    startHour, startMin, startSuffix = starts.parts
    endHour, endMin, endSuffix = ends.parts
    startSuffix = "" if startSuffix == endSuffix
    if in_parts
      [[startHour,startMin,startSuffix].join(''),
       [endHour,endMin,endSuffix].join('')]
    else
      [startHour,startMin,startSuffix,' - ',endHour,endMin,endSuffix].join("")
    end
  end  

  def date_and_times
    "#{starts.date.to_s(:day_month_date)}, #{times}"
  end

  def conflicts_with?(other, user)
    # easy tests: no conflict if any of:
    #   - other is this screening
    #   - other ends well before this starts
    #   - other starts well after this ends
    #   - same venue (can't possibly conflict)
    #   - different festivals (a sanity check)
    return false if (self == other) or \
                    ((starts - other.ends) > MAX_TRAVEL_TIME) or \
                    ((other.starts - ends) > MAX_TRAVEL_TIME) or \
                    (venue_id == other.venue_id) or \
                    (festival_id != other.festival_id)

    # they don't directly overlap; consider travel time. Which is first?
    if starts < other.starts # we go from this to the other
      (other.starts - ends) < festival.travel_interval_for(location, other.location, user)
    else # we go from there to here
      (starts - other.ends) < festival.travel_interval_for(other.location, location, user)
    end
  end

  def conflicts(user, all_screenings_by_day=nil)
    all_screenings_by_day ||= festival.screenings.all.group_by{|s| s.starts.to_date}
    all_screenings_by_day[starts.to_date].select {|other| conflicts_with?(other, user) }
  end
  
  def conflicting_picks(user, all_screenings_by_day=nil)
    # Find this user's picks for screenings that conflict with this one
    user.picks.all(:conditions => { :screening_id => conflicts(user, all_screenings_by_day).map {|s| s.id } },
                   :include => [:screening, :film])
  end

  def priority_for(user)
    film.picks.find_by_user_id(user.id).try(:priority)
  end

  def set_state(user, state)
    # :pick or :unpick this screening for this user.
    # If we're picking, unpick any conflicting screenings
    # Return a list of the screenings that changed, so we can update the UI.
    pick = film.picks.find_or_initialize_by_user_id(user.id)
    current_state = id == pick.screening_id ? :picked : :unpicked
    return [] if current_state == state # no screenings changed

    changed_screenings = [ ]
    film.screenings.each { |s| changed_screenings << s }

    if state == :picked # we're picking
      # Unpick conflicting screenings
      conflicting_picks(user).each do |p|
        p.film.screenings.each { |s| changed_screenings << s }
        p.screening = nil
        p.save!
      end

      # Note that the old picked screening changed (if any)
      changed_screenings << pick.screening if pick.picked?

      # Pick this screening
      pick.screening = self
    else
      # Just unpick this screening
      pick.screening = nil
    end
    pick.save!
    changed_screenings.uniq
  end
  
  def to_xml_with_options(options={})
    options[:only] ||= [:starts, :ends]
    options[:include] ||= [:venue]
    to_xml_without_options(options)
  end
  alias_method_chain :to_xml, :options

  def users_to_notify
    picks.map{|p| p.user }.select{|u| !u.mail_opt_out }
  end

  def notify_users_of_cancellation
    Mailer.deliver_schedule_changed(self, users_to_notify, :cancellation)
  end

  def notify_users_of_change
    Mailer.deliver_schedule_changed(self, users_to_notify, :change)
  end

protected
  def check_foreign_keys
    self.festival_id = film.festival_id if festival_id.nil? and not film.nil?
    self.location_id = venue.location_id if location_id.nil? and not venue.nil?
  end
  
  def check_duration
    self.ends = starts + film.duration unless film.nil?
  end
end
