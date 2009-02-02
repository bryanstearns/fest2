require 'restriction' # required due to http://rails.lighthouseapp.com/projects/8994/tickets/647-serialize-d-array-not-unserializing-properly

class Subscription < ActiveRecord::Base
  belongs_to :festival
  belongs_to :user
  serialize :restrictions
  
  validates_presence_of :festival_id
  validates_presence_of :user_id
  validate :check_restrictions

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
end
