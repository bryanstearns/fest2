require 'ruby-debug'

class Screening < ActiveRecord::Base
  belongs_to :film
  belongs_to :festival
  belongs_to :venue
  
  has_many :picks

  before_validation :check_foreign_keys, :check_duration
  validates_presence_of :festival_id
  validates_presence_of :film_id
  validates_presence_of :venue_id
  validates_presence_of :starts
  validates_presence_of :ends
  validates_each [:ends] do |record, attrib, value|
    if !value.nil? and !record.starts.nil? and value < record.starts
      record.errors.add(attrib, "isn't after Starts")
    end
  end
  
  def duration
    ends - starts
  end

  def inspect
    "#<Screening id: #{id}, festival: #{festival_id.nil? ? "nil" : festival.name}, film: #{film_id.nil? ? "nil" : film.name}, times: #{starts.to_date} #{times}, venue: #{venue.name}>"
  end
  
  def times
    startHour, startMin, startSuffix = starts.parts
    endHour, endMin, endSuffix = ends.parts
    startSuffix = "" if startSuffix == endSuffix
    [startHour,startMin,startSuffix,' - ',endHour,endMin,endSuffix].join("")
  end  

  def date_and_times
    "#{starts.date.to_s} #{times}"
  end

  def conflicts_with(other)
    return (starts < other.ends and ends > other.starts and \
           festival == other.festival)
  end
  
  def conflicting_picks(user)
    # Find this user's picks for screenings that conflict with this one
    # (the resulting list will include this one too).
    result = Pick.conflicting(self, user.id)
    result
  end
  
  def set_state(user, state)
    # :pick or :unpick this screening for this user.
    # If we're picking, unpick any conflicting screenings
    # Return a list of the screenings that changed, so we can update the UI.
    pick = film.picks.find_or_initialize_by_user_id(user.id)
    current_state = id == pick.screening_id ? :picked : :unpicked
    return [] if current_state == state # no screenings changed

    changed_screenings = [ self ]

    if state == :picked # we're picking
      # Unpick conflicting screenings
      conflicting_picks(user).reject {|p| p.id == pick.id }.each do |p|
        changed_screenings << p.screening
        p.screening = nil
        p.save!
      end

      # Note that the old picked screening changed (if any)
      changed_screenings << pick.screening unless pick.screening.nil?

      # Pick this screening
      pick.screening = self
    else
      # Just unpick this screening
      pick.screening = nil
    end
    pick.save!
    changed_screenings
  end
  
protected
  def check_foreign_keys
    self.festival_id = film.festival_id if festival_id.nil? and not film.nil?
  end
  
  def check_duration
    self.ends = starts + film.duration unless film.nil?
  end
end
