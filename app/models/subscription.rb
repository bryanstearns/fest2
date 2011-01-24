require 'time_restriction' # required due to http://rails.lighthouseapp.com/projects/8994/tickets/647-serialize-d-array-not-unserializing-properly

class Subscription < ActiveRecord::Base
  belongs_to :festival
  belongs_to :user
  serialize :time_restrictions
  serialize :excluded_venues
  
  validates_presence_of :festival_id
  validates_presence_of :user_id
  validate :check_time_restrictions
  validate :check_venue_exclusions

  before_save :make_sharable_key

  def can_see?(screening)
    return false if screening.press and not show_press
    return false if time_restrictions && time_restrictions.any? { |r| r.overlaps? screening }
    return false if excluded_venues && excluded_venues.include?(screening.venue.group_key)
    return true
  end

  def time_restriction_text
    @raw_time_restriction_text || TimeRestriction.to_text(time_restrictions)
  end

  def time_restriction_text=(s)
    begin
      @time_restrictions_error = @raw_time_restriction_text = nil
      self.time_restrictions = TimeRestriction.parse(s, festival.starts)
    rescue ArgumentError => e
      @raw_time_restriction_text = s
      @time_restrictions_error = e.message
    end
  end

  def check_time_restrictions
    if @time_restrictions_error
      errors.add("time_restriction_text", "is invalid (#{@time_restrictions_error})")
      @time_restrictions_error = nil
    end
  end

  def included_venue_groups
    festival_venue_group_keys - (excluded_venues || [])
  end

  def included_venue_groups=(venue_keys)
    excluded_list = festival.venues_grouped_by_key.keys - venue_keys.map{|vk| vk.to_sym }
    self.excluded_venues = excluded_list.present? ? excluded_list : nil
  end

  def festival_venue_group_keys
    @festival_venue_group_keys ||= festival.venues_grouped_by_key.keys
  end

  def check_venue_exclusions
    errors.add_to_base("You can't exclude all venues")\
      if festival && festival_venue_group_keys.map {|k| k.to_s } == self.excluded_venues
  end


  # A virtual attribute, set by the subscription-editing form
  # for passing through to the autoscheduler
  def unselect
    @unselect || "future"
  end

  def unselect=(s)
    @unselect = s
  end

  def make_sharable_key
    write_attribute(:key, Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{user_id}--")[0..7]) \
      unless read_attribute(:key)
  end

  def sharable_path
    "/festivals/#{festival_id}/#{user.username}/#{key}"
  end
end
