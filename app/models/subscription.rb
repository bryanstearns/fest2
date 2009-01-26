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
end
