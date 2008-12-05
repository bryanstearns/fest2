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
  
  named_scope :conflicting, lambda { |screening, user_id|
    { :include => [:screening, :film], 
      :conditions => [ "picks.user_id = :user_id and picks.festival_id = :festival_id and screenings.starts < :ends and screenings.ends > :starts",
                       { :user_id => user_id, :festival_id => screening.festival_id,
                         :starts => screening.starts, :ends => screening.ends }],
    }
  }

  def inspect
    festival_name = festival.slug rescue "nil"
    film_name = film.name rescue "nil"
    screening_times = screening.times rescue "nil"
    "#<Pick id:#{id} festival:#{festival_name} film:#{film_name} priority:#{priority} screening:#{screening_times}>"
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
