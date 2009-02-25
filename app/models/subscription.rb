require 'restriction' # required due to http://rails.lighthouseapp.com/projects/8994/tickets/647-serialize-d-array-not-unserializing-properly

class Subscription < ActiveRecord::Base
  belongs_to :festival
  belongs_to :user
  serialize :restrictions
  
  validates_presence_of :festival_id
  validates_presence_of :user_id
  validate :check_restrictions

  before_save :make_sharable_key

  def can_see?(screening)
    return false if screening.press and not show_press
    restrictions.nil? || !restrictions.any? { |r| r.overlaps? screening }
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
    "/festivals/#{festival_id}/#{user.login}/#{key}"
  end
end
