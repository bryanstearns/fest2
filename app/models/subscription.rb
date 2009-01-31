require 'restriction' # required due to http://rails.lighthouseapp.com/projects/8994/tickets/647-serialize-d-array-not-unserializing-properly

class Subscription < ActiveRecord::Base
  belongs_to :festival
  belongs_to :user
  serialize :restrictions
  
  validates_presence_of :festival_id
  validates_presence_of :user_id

  def can_see?(screening)
    return false if screening.press and not show_press
    restrictions.nil? || !restrictions.any? { |r| r.overlaps? screening }
  end

  def restriction_text
    return "" unless restrictions
    @restriction_text ||= restrictions.map(&:to_s).join(", ")
    @restriction_text
  end

  def restriction_text=(s)
    @restriction_text = s
    new_restrictions = Restriction.parse(s, festival.starts)
  end
end
