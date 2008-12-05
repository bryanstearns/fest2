require 'icalendar'

class Festival < ActiveRecord::Base
  include Icalendar
  include ActionController::UrlWriter

  has_many :films, :dependent => :destroy
  has_many :venues, :dependent => :destroy
  has_many :screenings # destroyed with film
  has_many :picks # destroyed with film
  has_many :subscriptions, :dependent => :destroy
  has_many :users, :through => :subscriptions
  
  validates_presence_of :name
  validates_uniqueness_of :name
  validates_presence_of :slug
  validates_uniqueness_of :slug
  validates_presence_of :starts
  validates_presence_of :ends
  validates_each [:ends] do |record, attrib, value|
    if !value.nil? and !record.starts.nil? and value < record.starts
      record.errors.add(attrib, "isn't after Starts")
    end
  end
  validates_format_of :film_url_format, :with => /^https?\:\/\/[^\/]+\/[^\*]*\*[^\*]*$/,
    :unless => Proc.new {|festival| festival.film_url_format.blank? },
    :message => "must be blank, or a URL with a '*' where the film identifier should go"
  
  # "slug" is now an independent (required) field.
  # before_save {|festival| festival.slug = festival.name.gsub(/[^a-z0-9]+/i, '-') }
  
  named_scope :unlimited, :conditions => [], :order => "starts desc"
  named_scope :conferences, :conditions => ['public = ? and is_conference = ?', true, true], :order => "starts desc"
  named_scope :festivals, :conditions => ['public = ? and is_conference = ?', true, false], :order => "starts desc"
  
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
  
  def to_ical(user_id)
    cal = Calendar.new
    screenings = picks.find_all_by_user_id(user_id).map(&:screening).compact.sort_by(&:starts)
    screenings.each do |s|
      e = Event.new
      e.start = s.starts.to_datetime
      e.end = s.ends.to_datetime
      e.location = s.venue.name
      e.summary = s.film.name
      e.klass = "PUBLIC"
      e.uid = yield s if block_given?
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
    now = Time.now
    picks.find_all_by_user_id(user.id, :conditions => "screening_id is not null").each do |p|
      if (not future_only) or p.screening.starts > now
        p.screening = nil
        p.save!
      end
    end
  end
end
