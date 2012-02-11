class Pick < ActiveRecord::Base
  RATING_HINTS = [
    nil,
    "It was bad",
    "It wasn't very good",
    "It was ok",
    "It was pretty good",
    "It was *really* good"
  ]

  belongs_to :film
  belongs_to :user
  belongs_to :screening
  belongs_to :festival
  
  before_validation :check_foreign_keys
  validates_presence_of :film_id
  validates_presence_of :user_id
  validates_presence_of :festival_id
  # :screening_id can be nil until we or the user has picked one.

  named_scope :for_user, lambda {|user|
    { :conditions => ['picks.user_id = ?', user.id] }
  }

  named_scope :rated, :conditions => 'rating > 0',
                      :order => 'rating desc, films.name',
                      :include => 'film'

  def picked?
    screening_id.present?
  end

  def inspect
    festival_name = festival.slug rescue "nil"
    film_name = film.name rescue "nil"
    screening_times = screening.times rescue "nil"
    "#<Pick id:#{id} festival:#{festival_name} film:#{film_name} priority:#{priority} rating:#{rating} screening:#{screening_times}>"
  end

protected
  def check_foreign_keys
    self.film = screening.film if film.nil? and not screening.nil?
    self.festival_id = film.festival_id if festival_id.nil? and not film.nil?
  end
end
