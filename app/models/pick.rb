class Pick < ActiveRecord::Base
  belongs_to :film
  belongs_to :user
  belongs_to :screening
  belongs_to :festival
  
  before_validation :check_foreign_keys
  validates_presence_of :film_id
  validates_presence_of :user_id
  validates_presence_of :festival_id
  # :screening_id can be nil until we or the user has picked one.

  def inspect
    "#<Pick id:#{id} festival:#{festival.nil? ? "nil" : festival.name[0...4]} film:#{film.nil? ? "nil" : film.name} priority:#{priority} screening:#{screening.nil? ? "nil" : screening.times}>"
  end

#  def conflicts
#    # Find picks for screenings that conflict with this one, but 
#    # exclude this one.
#    result = Pick.find_all_by_festival_id_and_user_id(festival_id, user_id, 
#        :include => [:screening, :film], :conditions => [
#           "starts <= :ends", # AND ends >= :starts",
#           { :starts => screening.starts, :ends => screening.ends }]
#    ).reject {|p| p.id == id }
#    result
#  end

protected
  def check_foreign_keys
    self.film = screening.film if film.nil? and not screening.nil?
    self.festival_id = film.festival_id if festival_id.nil? and not film.nil?
  end

end
