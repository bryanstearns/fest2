require 'restriction' # required due to http://rails.lighthouseapp.com/projects/8994/tickets/647-serialize-d-array-not-unserializing-properly

class Subscription < ActiveRecord::Base
  belongs_to :festival
  belongs_to :user
  serialize :restrictions
  serialize :excluded_venues
  
  validates_presence_of :festival_id
  validates_presence_of :user_id
  validate :check_restrictions
  validate :check_venue_exclusions

  before_save :make_sharable_key

  def can_see?(screening)
    return false if screening.press and not show_press
    return false if restrictions && restrictions.any? { |r| r.overlaps? screening }
    return false if excluded_venues && excluded_venues.include?(screening.venue.group_key)
    return true
  end

  def restriction_text
    @raw_restriction_text || Restriction.to_text(restrictions)
  end

  def restriction_text=(s)
    begin
      @restrictions_error = @raw_restriction_text = nil
      self.restrictions = Restriction.parse(s, festival.starts)
    rescue ArgumentError => e
      @raw_restriction_text = s
      @restrictions_error = e.message
    end
  end

  def check_restrictions
    if @restrictions_error
      errors.add("restriction_text", "is invalid (#{@restrictions_error})")
      @restrictions_error = nil
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
