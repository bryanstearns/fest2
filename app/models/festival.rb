require 'icalendar'

class Festival < CachedModel
  include Icalendar
  include ActionController::UrlWriter

  has_many :films, :dependent => :destroy
  has_many :venue_groups, :dependent => :destroy
  has_many :venues # destroyed with venue group
  has_many :screenings # destroyed with film
  has_many :picks # destroyed with film
  has_many :subscriptions, :dependent => :destroy
  has_many :users, :through => :subscriptions
  
  validates_presence_of :name, :slug, :slug_group, :starts, :ends
  validates_uniqueness_of :name, :slug
  validates_each [:ends] do |record, attrib, value|
    if !value.nil? and !record.starts.nil? and value < record.starts
      record.errors.add(attrib, "isn't after Starts")
    end
  end
  validates_format_of :film_url_format, :with => /^https?\:\/\/[^\/]+\/[^\*]*\*[^\*]*$/,
    :unless => Proc.new {|festival| festival.film_url_format.blank? },
    :message => "must be blank, or a URL with a '*' where the film identifier should go"

  before_validation :save_slug_group

  named_scope :unlimited, :conditions => [], :order => "starts desc"
  named_scope :published, :conditions => ['public = ?', true], :order => "starts desc"
  named_scope :published_and_scheduled, :conditions => ['public = ? and scheduled = ?', true, true], :order => "starts desc"
  named_scope :current, lambda { { :conditions => ['ends >= ?', 3.days.from_now] } }
  named_scope :in_slug_group, lambda {|group| { :conditions => ['slug_group = ?', group] } }

  cattr_accessor :show_buzz
  self.show_buzz = Rails.env.development?

  def self.best_default
    # For new users, the best festival to show is the next one that hasn't ended yet.
    # If there isn't one, just show the most-recent one
    # (Note that published_and_scheduled sorts newest-first!)
    Festival.published_and_scheduled.first(:conditions => ['ends >= ?', 3.days.from_now]) \
      || Festival.published_and_scheduled.first
  end

  def dates
    startish = "#{Date::MONTHNAMES[starts.month]} #{starts.day}"
    startish += ", #{starts.year}" if starts.year != ends.year or starts == ends
    return startish if starts == ends
    endish = (starts.month != ends.month) ? "#{Date::MONTHNAMES[ends.month]} " : ""
    endish += "#{ends.day}, #{ends.year}"
    "#{startish} - #{endish}"
  end
  
  def duration
    ends - starts
  end
  
  def to_param
    slug
  end

  def revision_time
    revised_at || created_at
  end

  def to_xml_with_options(options={})
    options[:only] ||= [:name, :location, :starts, :ends, :revised_at]
    options[:include] ||= [:films]
    to_xml_without_options(options)
  end
  alias_method_chain :to_xml, :options

  def to_csv
    screenings.sort_by(&:starts).map do |screening|
      film = screening.film
      name = film.name
      name += " (#{film.country_names})" unless film.countries.blank?
      result = [
        screening.starts.to_s(:csv),
        screening.venue.abbrev,
        "\"#{name}\"",
        screening.ends.to_s(:csv)
      ]
      result.join(',')
    end.join("\n")
  end

  def to_ics(user_id)
    cal = Calendar.new
    tzid = Time.zone.tzinfo.name # eg "America/Los_Angeles"
    screenings = picks.find_all_by_user_id(user_id).map(&:screening).compact.sort_by(&:starts)
    screenings.each do |s|
      e = Event.new
      e.start = s.starts.to_datetime
      e.end = s.ends.to_datetime
      e.start.ical_params = { "TZID" => tzid }
      e.end.ical_params = { "TZID" => tzid }
      e.location = s.venue.name
      e.summary = s.film.name
      e.klass = "PUBLIC"
      url = yield s if block_given?
      e.url = e.uid = url
      cal.add_event e
    end
    cal.to_ical
  end
  
  def external_film_url(film)
    # If the festival has a film_url_format, it should
    # be a URL with a * where the film identifier should go
    # If it doesn't, the film's fragment should be a full URL.
    # If the film has no fragment, return nil.
    return nil if film.url_fragment.blank?
    return film.url_fragment if film.url_fragment.include? "://"
    return nil if film_url_format.blank?
    film_url_format.sub("*", film.url_fragment)
  end

  def reset_rankings(user)
    picks.find_all_by_user_id(user.id, :conditions => "priority is not null").each do |p|
      p.priority = nil
      p.save!
    end    
  end
  
  def reset_screenings(user, future_only=false)
    now = Time.zone.now
    picks.find_all_by_user_id(user.id, :conditions => "screening_id is not null").each do |p|
      if (not future_only) or p.screening.starts > now
        Rails.logger.info "Resetting: #{p.screening.inspect}"
        p.screening = nil
        p.save!
      end
    end
  end

  def has_press_screenings?
    screenings.any?(&:press)
  end

  def save_slug_group
    self.slug_group = slug.split('_').first \
      if slug && (slug_changed? or slug_group.nil?)
  end

  # TODO: replace
  #def venue_groups
  #  @venue_groups ||= venues.map {|v| v.group }.uniq.sort
  #end
  #
  #def venues_grouped_by_key
  #  @venues_grouped_by_key ||= venues.all(:order => :name).group_by {|v| v.group_key}
  #end
end
